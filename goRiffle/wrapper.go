package goRiffle

import (
	"fmt"

	"github.com/exis-io/core"
)

// This is badly out of date. Can't enforce Cumin with left side return arguments
type Domain interface {
	Subscribe(string, interface{}) error
	Register(string, interface{}) error

	Publish(string, ...interface{}) error
	Call(string, ...interface{}) error

	Unsubscribe(string) error
	Unregister(string) error

	Join() error
	Leave() error
	Run()
}

type mantle struct {
	honcho core.App
	conn   *WebsocketConnection
}

type domain struct {
	mantle   *mantle
	mirror   core.Domain
	handlers map[uint]interface{}
	kill     chan bool
}

var wrap *mantle

func NewDomain(name string) Domain {

	if wrap == nil {
		h := core.NewApp()

		wrap = &mantle{
			honcho: h,
		}
	}

	d := domain{
		mantle:   wrap,
		handlers: make(map[uint]interface{}),
		kill:     make(chan bool),
	}

	d.mirror = wrap.honcho.NewDomain(name)
	return d
}

func (d domain) Subscribe(endpoint string, handler interface{}) error {
	id := core.NewID()
	if err := d.mirror.Subscribe(endpoint, id, []interface{}{}); err != nil {
		return err
	} else {
		d.handlers[id] = handler
		return nil
	}
}

func (d domain) Register(endpoint string, handler interface{}) error {
	id := core.NewID()
	if err := d.mirror.Register(endpoint, id, []interface{}{}); err != nil {
		return err
	} else {
		d.handlers[id] = handler
		return nil
	}
}

func (d domain) Publish(endpoint string, args ...interface{}) error {
	id := core.NewID()
	err := d.mirror.Publish(endpoint, id, args)
	return err
}

func (d domain) Call(endpoint string, args ...interface{}) error {
	id := core.NewID()
	err := d.mirror.Call(endpoint, id, args)
	return err
}

func (d domain) Unsubscribe(endpoint string) error {
	err := d.mirror.Unsubscribe(endpoint)
	return err
}

func (d domain) Unregister(endpoint string) error {
	err := d.mirror.Unregister(endpoint)
	return err
}

func (d domain) Join() error {
	// Open a new connection if we don't have one yet
	if d.mantle.conn == nil {
		c, err := Open(core.LocalFabric)

		if err != nil {
			fmt.Println("Unable to open connection!")
			return err
		}

		c.App = wrap.honcho
		wrap.conn = c
		return d.mirror.Join(c)
	}

	return nil
}

func (d domain) Leave() error {
	err := d.mirror.Leave()

	// for each subscription
	// for each registration

	return err
}

func (d domain) Invoke(id uint, args []interface{}) {
	Debug("Called with %s", args)

	if handler, ok := d.handlers[id]; ok {
		core.Cumin(handler, args)
	}
}

// Spin and run while the domain is still connected
func (d domain) Run() {
	<-d.kill
}

func Debug(format string, a ...interface{}) {
	core.Debug(format, a...)
}

func Info(format string, a ...interface{}) {
	core.Info(format, a...)
}

func Warn(format string, a ...interface{}) {
	core.Warn(format, a...)
}

const (
	LogLevelErr   int = 0
	LogLevelWarn  int = 1
	LogLevelInfo  int = 2
	LogLevelDebug int = 3
)

func SetLoggingLevel(l int) {
	core.LogLevel = l
}

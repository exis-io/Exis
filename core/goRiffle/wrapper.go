package goRiffle

// import (
// 	"fmt"

// 	"github.com/exis-io/core"
// )

// type Domain interface {
// 	Subscribe(string, interface{}) error
// 	Register(string, interface{}) error

// 	Publish(string, ...interface{}) error
// 	Call(string, ...interface{}) ([]interface{}, error)

// 	Unsubscribe(string) error
// 	Unregister(string) error

// 	Join() error
// 	Leave() error
// 	Run()
// }

// type mantle struct {
// 	honcho core.App
// 	conn   *WebsocketConnection
// }

// type domain struct {
// 	mantle   *mantle
// 	mirror   core.Domain
// 	handlers map[uint]interface{}
// 	kill     chan bool
// }

// var wrap *mantle

// func NewDomain(name string) Domain {

// 	if wrap == nil {
// 		h := core.NewApp()

// 		wrap = &mantle{
// 			honcho: h,
// 		}
// 	}

// 	d := domain{
// 		mantle:   wrap,
// 		handlers: make(map[uint]interface{}),
// 		kill:     make(chan bool),
// 	}

// 	d.mirror = wrap.honcho.NewDomain(name, d)
// 	return d
// }

// func (d domain) Subscribe(endpoint string, handler interface{}) error {
// 	if i, err := d.mirror.Subscribe(endpoint, []interface{}{}); err != nil {
// 		return err
// 	} else {
// 		d.handlers[i] = handler
// 		return nil
// 	}
// }

// func (d domain) Register(endpoint string, handler interface{}) error {
// 	if i, err := d.mirror.Register(endpoint, []interface{}{}); err != nil {
// 		return err
// 	} else {
// 		d.handlers[i] = handler
// 		return nil
// 	}
// }

// func (d domain) Publish(endpoint string, args ...interface{}) error {
// 	err := d.mirror.Publish(endpoint, args)
// 	return err
// }

// func (d domain) Call(endpoint string, args ...interface{}) ([]interface{}, error) {
// 	args, err := d.mirror.Call(endpoint, args)
// 	return args, err
// }

// func (d domain) Unsubscribe(endpoint string) error {
// 	err := d.mirror.Unsubscribe(endpoint)
// 	return err
// }

// func (d domain) Unregister(endpoint string) error {
// 	err := d.mirror.Unregister(endpoint)
// 	return err
// }

// func (d domain) Join() error {
// 	// Open a new connection if we don't have one yet
// 	if d.mantle.conn == nil {
// 		c, err := Open(core.LocalFabric)

// 		if err != nil {
// 			fmt.Println("Unable to open connection!")
// 			return err
// 		}

// 		c.App = wrap.honcho
// 		wrap.conn = c
// 		return d.mirror.Join(c)
// 	}

// 	return nil
// }

// func (d domain) Leave() error {
// 	err := d.mirror.Leave()

// 	// for each subscription
// 	// for each registration

// 	return err
// }

// func (d domain) Invoke(id uint, args []interface{}) ([]interface{}, error) {
// 	return core.Cumin(d.handlers[id], args)
// }

// func (d domain) OnJoin(string) {
// 	fmt.Println("Delegate joined!")
// }

// func (d domain) OnLeave(string) {
// 	fmt.Println("Delegate left!!")
// 	d.kill <- true
// }

// // Spin and run while the domain is still connected
// func (d domain) Run() {
// 	<-d.kill
// }

// func Debug(format string, a ...interface{}) {
// 	core.Debug(format, a...)
// }

// func Info(format string, a ...interface{}) {
// 	core.Info(format, a...)
// }

// func Warn(format string, a ...interface{}) {
// 	core.Warn(format, a...)
// }

// const (
// 	LogLevelErr   int = 0
// 	LogLevelWarn  int = 1
// 	LogLevelInfo  int = 2
// 	LogLevelDebug int = 3
// )

// func SetLoggingLevel(l int) {
// 	core.LogLevel = l
// }

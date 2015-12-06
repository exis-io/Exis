// package name: reef
package main

import (
	"fmt"

	"github.com/exis-io/coreRiffle"
	"github.com/gopherjs/gopherjs/js"
)

// A good resource on working with gopherjs
// http://legacytotheedge.blogspot.de/2014/03/gopherjs-go-to-javascript-transpiler.html

type wrapper struct {
	honcho coreRiffle.Honcho
	// conn   *websocketConnection
}

type domain struct {
	wrapper  *wrapper
	mirror   coreRiffle.Domain
	handlers map[uint]interface{}
	kill     chan bool
}

type Domain interface {
	Subscribe(string, interface{}) error
	Register(string, interface{}) error

	Publish(string, ...interface{}) error
	Call(string, ...interface{}) ([]interface{}, error)

	Unsubscribe(string) error
	Unregister(string) error

	Join() error
	Leave() error
	Run()
}

var wrap *wrapper

// Required main method
func main() {
	js.Global.Set("wrapper", map[string]interface{}{
		"HelloWorld": HelloWorld,
		"SetLogging": SetLogging,
	})

	js.Global.Set("Dom", map[string]interface{}{
		"NewDomain": NewDomain,
	})

	js.Global.Set("pet", map[string]interface{}{
		"New": New,
	})
}

func HelloWorld(a string) {
	fmt.Println("GO: Hello, world called")
	// return "Hi, " + a
}

// Pet Testing
type Pet struct {
	name string
}

func (p *Pet) Name() string {
	return p.name
}

func (p *Pet) SetName(newName string) {
	p.name = newName
}

func New(name string) *js.Object {
	return js.MakeWrapper(&Pet{name})
}

// End pet testing

func NewDomain(name string) *js.Object {
	fmt.Println("Created a new domain")

	if wrap == nil {
		h := coreRiffle.NewHoncho()

		wrap = &wrapper{
			honcho: h,
		}
	}

	d := domain{
		wrapper:  wrap,
		handlers: make(map[uint]interface{}),
		kill:     make(chan bool),
	}

	d.mirror = wrap.honcho.NewDomain(name, d)

	// fmt.Println("Created domain: ", d)

	return js.MakeWrapper(&d)
	// return d
}

func (d *domain) Subscribe(endpoint string, handler interface{}) error {
	if i, err := d.mirror.Subscribe(endpoint, []interface{}{}); err != nil {
		return err
	} else {
		d.handlers[i] = handler
		return nil
	}
}

func (d *domain) Register(endpoint string, handler interface{}) error {
	if i, err := d.mirror.Register(endpoint, []interface{}{}); err != nil {
		return err
	} else {
		d.handlers[i] = handler
		return nil
	}
}

func (d *domain) Publish(endpoint string, args ...interface{}) error {
	err := d.mirror.Publish(endpoint, args)
	return err
}

func (d *domain) Call(endpoint string, args ...interface{}) ([]interface{}, error) {
	args, err := d.mirror.Call(endpoint, args)
	return args, err
}

func (d *domain) Unsubscribe(endpoint string) error {
	err := d.mirror.Unsubscribe(endpoint)
	return err
}

func (d *domain) Unregister(endpoint string) error {
	err := d.mirror.Unregister(endpoint)
	return err
}

func (d *domain) Join() error {
	// Open a new connection if we don't have one yet
	// if d.wrapper.conn == nil {
	// 	c, err := Open(coreRiffle.LocalFabric)

	// 	if err != nil {
	// 		fmt.Println("Unable to open connection!")
	// 		return err
	// 	}

	// 	c.Honcho = wrap.honcho
	// 	wrap.conn = c
	// 	return d.mirror.Join(c)
	// }

	return nil
}

func (d *domain) Leave() error {
	err := d.mirror.Leave()

	// for each subscription
	// for each registration

	return err
}

func (d domain) Invoke(endpoint string, id uint, args []interface{}) ([]interface{}, error) {
	// return coreRiffle.Cumin(d.handlers[id], args)
	return nil, nil
}

func (d domain) OnJoin(string) {
	fmt.Println("Delegate joined!")
}

func (d domain) OnLeave(string) {
	fmt.Println("Delegate left!!")
	d.kill <- true
}

// Spin and run while the domain is still connected
func (d *domain) Run() {
	<-d.kill
}

// Debugging functions
func Debug(format string, a ...interface{}) {
	coreRiffle.Debug(format, a...)
}

func Info(format string, a ...interface{}) {
	coreRiffle.Info(format, a...)
}

func Warn(format string, a ...interface{}) {
	coreRiffle.Warn(format, a...)
}

const (
	LOGWARN  int = 1
	LOGINFO  int = 2
	LOGDEBUG int = 3
)

func SetLogging(level int) {
	coreRiffle.SetLogging(level)
}

// JS Specific, get the connection inside somehow
func Open() {

}

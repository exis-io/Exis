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
	app    coreRiffle.App
	conn   *js.Object
	opened chan bool
}

type domain struct {
	wrapper  *wrapper
	mirror   coreRiffle.Domain
	handlers map[uint]*js.Object
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
}

var wrap *wrapper

// Required main method
func main() {
	js.Global.Set("Core", map[string]interface{}{
		"SetLoggingDebug": coreRiffle.SetLoggingDebug,
		"SetLoggingInfo":  coreRiffle.SetLoggingInfo,
		"SetLoggingWarn":  coreRiffle.SetLoggingWarn,
	})

	// Change Wrapper to Pool
	js.Global.Set("Wrapper", map[string]interface{}{
		"New":              NewWrapper,
		"SetConnection":    SetConnection,
		"ConnectionOpened": ConnectionOpened,
		"NewMessage":       NewMessage,
	})

	js.Global.Set("Domain", map[string]interface{}{
		"New": NewDomain,
	})

	// coreRiffle.SetLogWriter()
}

/////////////////////////////////////////////
// Connection Wrapper
/////////////////////////////////////////////

func NewWrapper() {
	if wrap == nil {
		h := coreRiffle.NewApp()

		wrap = &wrapper{
			app:    h,
			opened: make(chan bool),
		}
	}
}

func (w *wrapper) Send(data []byte) {
	w.conn.Call("send", string(data))
}

func (w *wrapper) Close(reason string) error {
	w.conn.Call("close", 1000, reason)
	return nil
}

// Call SetConnection, then Join
func SetConnection(c *js.Object) {
	fmt.Println("Connection set: ", c)
	wrap.conn = c
	// c.Set("onmessage", wrap.app.ReceiveString)
}

func NewMessage(c *js.Object) {
	fmt.Println("Message Receive: ", c.String())
	wrap.app.ReceiveString(c.String())
}

func ConnectionOpened() {
	wrap.opened <- true
}

/////////////////////////////////////////////
// Domain Functions
/////////////////////////////////////////////

func NewDomain(name string) *js.Object {
	fmt.Println("Created a new domain")

	if wrap == nil {
		fmt.Println("WARN: wrapper hasn't been created yet!")
	}

	d := domain{
		wrapper:  wrap,
		handlers: make(map[uint]*js.Object),
		kill:     make(chan bool),
	}

	d.mirror = wrap.app.NewDomain(name, d)
	return js.MakeWrapper(&d)
}

func (d *domain) Subscribe(endpoint string, handler *js.Object) error {
	// Cute, but not the best idea long term. Deferreds are going to be easiest (?)
	go func() {
		if i, err := d.mirror.Subscribe(endpoint, []interface{}{}); err != nil {
			// return err
			fmt.Println("Unable to subscribe: ", err.Error())
		} else {
			// fmt.Println("Subscribedd with id, handler: ", i, handler)
			d.handlers[i] = handler
			// return nil
		}
	}()

	return nil
}

func (d *domain) Register(endpoint string, handler *js.Object) error {
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
	// If this domain doesnt have a pool, create one now and obtain a connection
	// If we can't call out because of the platform, the wrapper must push us a connection when a domain calls join

	go func() {
		// wait for onopen from the connection
		<-d.wrapper.opened
		d.mirror.Join(d.wrapper)
	}()

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
	d.handlers[id].Invoke(args)
	return nil, nil
}

func (d domain) OnJoin(string) {
	fmt.Println("Delegate joined!")
}

func (d domain) OnLeave(string) {
	fmt.Println("Delegate left!!")
	d.kill <- true
}

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
	conn   *js.Object
	opened chan bool
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
	// Change Riffle to Wrapper
	// js.Global.Set("Riffle", map[string]interface{}{
	// 	"SetLogging": SetLogging,
	// })

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

}

/////////////////////////////////////////////
// Connection Wrapper
/////////////////////////////////////////////

func NewWrapper() {
	if wrap == nil {
		h := coreRiffle.NewHoncho()

		wrap = &wrapper{
			honcho: h,
			opened: make(chan bool),
		}
	}
}

func (w *wrapper) Send(data []byte) {
	// fmt.Println("WARN: Cannot send binary data!")

	// var dat []interface{}

	// if err := json.Unmarshal(data, &dat); err != nil {
	// 	fmt.Println("unmarshal json! Message: ", dat)
	// } else {
	// 	fmt.Println("Unable to unmarshal message")
	// }

	// if str, ok := data.(*string); ok {
	// 	fmt.Println("message received: ", str)
	// } else {
	// 	fmt.Println("Unable to convert bytes to string!")
	// }

	w.conn.Call("send", string(data))
}

func (w *wrapper) SendString(json string) {
	w.conn.Call("send", json)
}

func (w *wrapper) Close(reason string) error {
	w.conn.Call("close", 1000, reason)
	return nil
}

// Call SetConnection, then Join
func SetConnection(c *js.Object) {
	fmt.Println("Connection set: ", c)
	wrap.conn = c
	// c.Set("onmessage", wrap.honcho.ReceiveString)
}

func NewMessage(c *js.Object) {
	// fmt.Println("Message Receive: ", c.String())
	wrap.honcho.ReceiveString(c.String())
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

	go func() {
		// wait for onopen from the connection
		<-d.wrapper.opened

		//Open a new connection if we don't have one yet
		// Ideally this should be created on the spot on demand

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
	fmt.Println("Invocation received!")
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

// JS Specific, get the connection inside somehow
// func Open() {

// }

// Pass in a connection object, set up handlers on it, and store it in the wrapper

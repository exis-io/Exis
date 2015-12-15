// package name: reef
package main

import (
	"fmt"

	// _ "github.com/augustoroman/promise"
	"github.com/exis-io/core"
	"github.com/gopherjs/gopherjs/js"
)

// A good resource on working with gopherjs
// http://legacytotheedge.blogspot.de/2014/03/gopherjs-go-to-javascript-transpiler.html

/*
TODO
    Remove fmt from core to reduce size of library
    Inject writer for logging and saving
*/

var fabric string = core.FabricLocal

func main() {
	// Functions are autoexported on non-pointer types-- dont need "Subdomain" listed here
	js.Global.Set("Domain", map[string]interface{}{
		"New": New,
	})

	js.Global.Set("Config", map[string]interface{}{
		"SetLogLevelOff":      SetLogLevelOff,
		"SetLogLevelApp":      SetLogLevelApp,
		"SetLogLevelErr":      SetLogLevelErr,
		"SetLogLevelWarn":     SetLogLevelWarn,
		"SetLogLevelInfo":     SetLogLevelInfo,
		"SetLogLevelDebug":    SetLogLevelDebug,
		"SetFabricDev":        SetFabricDev,
		"SetFabricSandbox":    SetFabricSandbox,
		"SetFabricProduction": SetFabricProduction,
		"SetFabricLocal":      SetFabricLocal,
		"SetFabric":           SetFabric,
		"Application":         Application,
		"Debug":               Debug,
		"Info":                Info,
		"Warn":                Warn,
		"Error":               Error,
	})

}

type Domain struct {
	coreDomain core.Domain
	wrapped    *js.Object
}

type Conn struct {
	wrapper *js.Object
	app     core.App
	domain  *Domain
}

func (c Conn) OnMessage(msg *js.Object) {
	c.app.ReceiveString(msg.String())
}

func (c Conn) OnOpen(msg *js.Object) {
	go c.domain.FinishJoin(&c)
}

func (c Conn) OnClose(msg *js.Object) {
	c.app.Close(msg.String())
}

func (c Conn) Send(data []byte) {
	c.wrapper.Get("conn").Call("send", string(data))
}

func (c Conn) Close(reason string) error {
	fmt.Println("Asked to close: ", reason)
	c.wrapper.Get("conn").Call("close", 1001, reason)
	return nil
}

func (c Conn) SetApp(app core.App) {
	c.app = app
}

func New(name string) *js.Object {
	d := Domain{
		coreDomain: core.NewDomain(name, nil),
	}

	d.wrapped = js.MakeWrapper(&d)
	return d.wrapped
}

func (d *Domain) Subdomain(name string) *js.Object {
	n := Domain{
		coreDomain: d.coreDomain.Subdomain(name),
	}

	n.wrapped = js.MakeWrapper(&n)
	return n.wrapped
}

// var conn Conn

// Blocks on callbacks from the core.
// TODO: trigger a close meta callback when connection is lost
func (d *Domain) Receive() string {
	return core.MantleMarshall(d.coreDomain.GetApp().CallbackListen())
}

func (d *Domain) Join() {
	w := js.Global.Get("WsWrapper")

	conn := Conn{
		wrapper: w,
		domain:  d,
		app:     d.coreDomain.GetApp(),
	}

	w.Set("onmessage", conn.OnMessage)
	w.Set("onopen", conn.OnOpen)
	w.Set("onclose", conn.OnClose)

	w.Call("open", fabric)
}

func (d Domain) OnJoin() {
	fmt.Println("Default onJoin")
}

// The actual join method
func (d *Domain) FinishJoin(c *Conn) {
	if err := d.coreDomain.Join(c); err != nil {
		// d.coreDomain.GetApp().CallbackSend(eb, err.Error())
		fmt.Println("Cant join: ", err)
	} else {
		// d.coreDomain.GetApp().CallbackSend(cb)
		fmt.Println("Joined!")

		// Only call onJoin if it exsts
		if j := d.wrapped.Get("onJoin"); j != js.Undefined {
			d.wrapped.Call("onJoin")
		}
	}

}

func (d *Domain) Subscribe(cb uint, endpoint string) {
	go func() {
		d.coreDomain.Subscribe(endpoint, cb, make([]interface{}, 0))
	}()
}

func (d *Domain) Register(cb uint, endpoint string) {
	go func() {
		d.coreDomain.Register(endpoint, cb, make([]interface{}, 0))
	}()
}

// Args are string encoded json
func (d *Domain) Publish(cb uint, endpoint string, args string) {
	go func() {
		d.coreDomain.Publish(endpoint, cb, core.MantleUnmarshal(args))
	}()
}

func (d *Domain) Call(cb uint, endpoint string, args string) {
	go func() {
		d.coreDomain.Call(endpoint, cb, core.MantleUnmarshal(args))
	}()
}

func (d *Domain) Yield(request uint, args string) {
	go func() {
		d.coreDomain.GetApp().Yield(request, core.MantleUnmarshal(args))
	}()
}

func (d *Domain) Unsubscribe(endpoint string) {
	go func() {
		d.coreDomain.Unsubscribe(endpoint)
	}()
}

func (d *Domain) Unregister(endpoint string) {
	go func() {
		d.coreDomain.Unregister(endpoint)
	}()
}

func (d *Domain) Leave() {
	go func() {
		d.coreDomain.Leave()
	}()
}

func SetLogLevelOff()   { core.LogLevel = core.LogLevelOff }
func SetLogLevelApp()   { core.LogLevel = core.LogLevelApp }
func SetLogLevelErr()   { core.LogLevel = core.LogLevelErr }
func SetLogLevelWarn()  { core.LogLevel = core.LogLevelWarn }
func SetLogLevelInfo()  { core.LogLevel = core.LogLevelInfo }
func SetLogLevelDebug() { core.LogLevel = core.LogLevelDebug }

func SetFabricDev()        { fabric = core.FabricDev }
func SetFabricSandbox()    { fabric = core.FabricSandbox }
func SetFabricProduction() { fabric = core.FabricProduction }
func SetFabricLocal()      { fabric = core.FabricLocal }
func SetFabric(url string) { fabric = url }

func Application(s string) { core.Application("%s", s) }
func Debug(s string)       { core.Debug("%s", s) }
func Info(s string)        { core.Info("%s", s) }
func Warn(s string)        { core.Warn("%s", s) }
func Error(s string)       { core.Error("%s", s) }

// Do we want a GetName? Most likely yes

/*
type wrapper struct {
	app    core.App
	conn   *js.Object
	opened chan bool
}

type domain struct {
	wrapper  *wrapper
	mirror   core.Domain
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
		"SetLoggingDebug": core.SetLoggingDebug,
		"SetLoggingInfo":  core.SetLoggingInfo,
		"SetLoggingWarn":  core.SetLoggingWarn,
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

	// core.SetLogWriter()
}

/////////////////////////////////////////////
// Connection Wrapper
/////////////////////////////////////////////

func NewWrapper() {
	if wrap == nil {
		h := core.NewApp()

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
	// return core.Cumin(d.handlers[id], args)
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
*/

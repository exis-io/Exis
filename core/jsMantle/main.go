package main

import (
	"fmt"

	"github.com/augustoroman/promise"
	"github.com/exis-io/core"
	"github.com/gopherjs/gopherjs/js"
)

func main() {
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

	// Do not print the log line number in js
	core.ShouldLogLineNumber = false
}

type Domain struct {
	coreDomain core.Domain
	wrapped    *js.Object
	app        *App
}

type Conn struct {
	wrapper *js.Object
	app     core.App
	domain  *Domain
}

type App struct {
	conn          Conn
	registrations map[uint64]*js.Object
	subscriptions map[uint64]*js.Object
}

type idGenerator struct{}

func (i idGenerator) NewID() uint64 {
	return js.Global.Get("NewID").Invoke().Uint64()
}

func (c Conn) OnMessage(msg *js.Object) {
	c.app.ReceiveBytes([]byte(msg.String()))
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
	core.Debug("Asked to close: ", reason)
	
	//TODO: Use appropriate error codes
	c.wrapper.Get("conn").Call("close", 1000, reason)
	return nil
}

func (c Conn) SetApp(app core.App) {
	c.app = app
}

func New(name string) *js.Object {
	core.ExternalGenerator = idGenerator{}

	a := &App{
		registrations: make(map[uint64]*js.Object),
		subscriptions: make(map[uint64]*js.Object),
	}

	d := Domain{
		coreDomain: core.NewDomain(name, nil),
		app:        a,
	}

	d.wrapped = js.MakeWrapper(&d)
	return d.wrapped
}

func (d *Domain) Subdomain(name string) *js.Object {
	n := Domain{
		coreDomain: d.coreDomain.Subdomain(name),
		app:        d.app,
	}

	n.wrapped = js.MakeWrapper(&n)
	return n.wrapped
}

func (d *Domain) LinkDomain(name string) *js.Object {
	n := Domain{
		coreDomain: d.coreDomain.LinkDomain(name),
		app:        d.app,
	}

	n.wrapped = js.MakeWrapper(&n)
	return n.wrapped
}

// Blocks on callbacks from the core.
// TODO: trigger a close meta callback when connection is lost
func (a *App) Receive() {
	for {
		cb := a.conn.app.CallbackListen()

		if cb.Id == 0 {
			// TODO: Trigger onLeave for all domains
			core.Info("Terminating receive loop")
			return
		}

		if fn, ok := a.subscriptions[cb.Id]; ok {
			fn.Invoke(cb.Args...)
		}

		if fn, ok := a.registrations[cb.Id]; ok {
			ret := fn.Invoke(cb.Args[1:]...)
			a.conn.app.Yield(cb.Args[0].(uint64), []interface{}{ret.Interface()})
		}
	}
}

// Part 1 of the join-- start the join
func (d *Domain) Join() {
	w := js.Global.Get("WsWrapper").New()

	conn := Conn{
		wrapper: w,
		domain:  d,
		app:     d.coreDomain.GetApp(),
	}

	d.app.conn = conn

	w.Set("onmessage", conn.OnMessage)
	w.Set("onopen", conn.OnOpen)
	w.Set("onclose", conn.OnClose)
	w.Call("open", core.Fabric)
}

// Part 2 of the join method-- complete the join
func (d *Domain) FinishJoin(c *Conn) {
	if err := d.coreDomain.Join(c); err != nil {
		fmt.Println("Join failed: ", err)
	} else {
		go d.app.Receive()

		if j := d.wrapped.Get("onJoin"); j != js.Undefined {
			d.wrapped.Call("onJoin")
		}
	}
}

func (d *Domain) Subscribe(endpoint string, handler *js.Object) *js.Object {
	cb := core.NewID()
	var p promise.Promise

	go func() {
		// From the want wrapper pull out the types they defined,
		// and pass them down into the core.
		h := handler.Get("types")
		tmp := h.Interface()
		types, hasTypes := tmp.([]interface{})

		// handler can either be:
		// 1. an object that contains "types" and "fp" attributes.
		// 2. a naked function, in which case we tell the core that it doesn't
		// care about types.
		handlerFunction := handler
		handlerTypes := []interface{}{nil}
		if hasTypes {
			handlerFunction = handler.Get("fp")
			handlerTypes = types
		}

		if err := d.coreDomain.Subscribe(endpoint, cb, handlerTypes); err == nil {
			d.app.subscriptions[cb] = handlerFunction
			p.Resolve(nil)
		} else {
			p.Reject(err)
		}
	}()

	return p.Js()
}

func (d *Domain) Register(endpoint string, handler *js.Object) *js.Object {
	cb := core.NewID()
	var p promise.Promise

	go func() {
		// From the want wrapper pull out the types they defined,
		// and pass them down into the core.
		h := handler.Get("types")
		tmp := h.Interface()
		types, hasTypes := tmp.([]interface{})

		// handler can either be:
		// 1. an object that contains "types" and "fp" attributes.
		// 2. a naked function, in which case we tell the core that it doesn't
		// care about types.
		handlerFunction := handler
		handlerTypes := []interface{}{nil}
		if hasTypes {
			handlerFunction = handler.Get("fp")
			handlerTypes = types
		}

		if err := d.coreDomain.Register(endpoint, cb, handlerTypes); err == nil {
			d.app.registrations[cb] = handlerFunction
			p.Resolve(nil)
		} else {
			p.Reject(err)
		}
	}()

	return p.Js()
}

func (d *Domain) Publish(endpoint string, args ...interface{}) *js.Object {
	return promisify(func() (interface{}, error) { return nil, d.coreDomain.Publish(endpoint, args) })
}

func (d *Domain) Call(endpoint string, args ...interface{}) *js.Object {
	return promisify(func() (interface{}, error) { return d.coreDomain.Call(endpoint, args) })
}

func (d *Domain) Unsubscribe(endpoint string) *js.Object {
	return promisify(func() (interface{}, error) { return nil, d.coreDomain.Unsubscribe(endpoint) })
}

func (d *Domain) Unregister(endpoint string) *js.Object {
	return promisify(func() (interface{}, error) { return nil, d.coreDomain.Unregister(endpoint) })
}

func (d *Domain) Leave() *js.Object {
	return promisify(func() (interface{}, error) { return nil, d.coreDomain.Leave() })
}

// Turn the given invocation into a JS promise. If the function returns an error, return the error,
// else return the results of the function
func promisify(fn func() (interface{}, error)) *js.Object {
	var p promise.Promise

	go func() {
		if results, err := fn(); err == nil {
			p.Resolve(results)
		} else {
			p.Reject(err.Error())
		}
	}()

	return p.Js()
}

func SetLogLevelOff()   { core.LogLevel = core.LogLevelOff }
func SetLogLevelApp()   { core.LogLevel = core.LogLevelApp }
func SetLogLevelErr()   { core.LogLevel = core.LogLevelErr }
func SetLogLevelWarn()  { core.LogLevel = core.LogLevelWarn }
func SetLogLevelInfo()  { core.LogLevel = core.LogLevelInfo }
func SetLogLevelDebug() { core.LogLevel = core.LogLevelDebug }

func SetFabricDev()        { core.Fabric = core.FabricDev }
func SetFabricSandbox()    { core.Fabric = core.FabricSandbox }
func SetFabricProduction() { core.Fabric = core.FabricProduction }
func SetFabricLocal()      { core.Fabric = core.FabricLocal }
func SetFabric(url string) { core.Fabric = url }

func Application(s string) { core.Application("%s", s) }
func Debug(s string)       { core.Debug("%s", s) }
func Info(s string)        { core.Info("%s", s) }
func Warn(s string)        { core.Warn("%s", s) }
func Error(s string)       { core.Error("%s", s) }

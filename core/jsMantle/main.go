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

// Blocks on callbacks from the core.
// TODO: trigger a close meta callback when connection is lost
func (a *App) Receive() {
	Debug("Starting receive")

	for {
		cb := a.conn.app.CallbackListen()
		core.Debug("Have callback: %v", cb)

		if cb.Id == 0 {
			// Trigger onLeave for all domains
			core.Info("Terminating receive loop")
			return
		}

		if fn, ok := a.subscriptions[cb.Id]; ok {
			core.Debug("Subscription: %v", cb.Args)
			// Call the JS function (via invoke), pass args as ... so they show
			// up in JS as a list, we can deal with splatting up there...
			fn.Invoke(cb.Args...)
		}

		if fn, ok := a.registrations[cb.Id]; ok {
			core.Debug("Invocation: %v", cb.Args[1:])
			// We need to stip out the first arg, its the yield id so we can return
			// with some results (since this is a reg)
			// Call the JS function (via invoke), pass args as ... so they show
			// up in JS as a list, we can deal with splatting up there...
			ret := fn.Invoke(cb.Args[1:]...)

			a.conn.app.Yield(cb.Args[0].(uint64), []interface{}{ret.Interface()})
		}
	}
}

func (d *Domain) Join() {
	w := js.Global.Get("WsWrapper")

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

// The actual join method
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
	var p promise.Promise

	go func() {
		if err := d.coreDomain.Publish(endpoint, args); err == nil {
			p.Resolve(nil)
		} else {
			p.Reject(err)
		}
	}()

	return p.Js()
}

func (d *Domain) Call(endpoint string, args ...interface{}) *js.Object {
	var p promise.Promise

	go func() {
		if results, err := d.coreDomain.Call(endpoint, args); err == nil {
			p.Resolve(results)
		} else {
			p.Reject(err.Error())
		}
	}()

	return p.Js()
}

func (d *Domain) Unsubscribe(endpoint string) *js.Object {
	var p promise.Promise

	go func() {
		if err := d.coreDomain.Unsubscribe(endpoint); err == nil {
			p.Resolve(nil)
		} else {
			p.Reject(err)
		}
	}()

	return p.Js()
}

func (d *Domain) Unregister(endpoint string) *js.Object {
	var p promise.Promise

	Info("Trying to unregister with")
	go func() {
		if err := d.coreDomain.Unregister(endpoint); err == nil {
			p.Resolve(nil)
		} else {
			p.Reject(err)
		}
	}()

	return p.Js()
}

func (d *Domain) Leave() *js.Object {
	var p promise.Promise

	go func() {
		if err := d.coreDomain.Leave(); err == nil {
			p.Resolve(nil)
		} else {
			p.Reject(err)
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

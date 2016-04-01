package main

import (
	"fmt"
	"strings"
	"time"

	"github.com/exis-io/core"
	"github.com/gopherjs/gopherjs/js"
)

func main() {
	js.Global.Set("Domain", map[string]interface{}{
		"New": New,
	})

	js.Global.Set("Config", map[string]interface{}{
		"setLogLevelOff":      SetLogLevelOff,
		"setLogLevelApp":      SetLogLevelApp,
		"setLogLevelErr":      SetLogLevelErr,
		"setLogLevelWarn":     SetLogLevelWarn,
		"setLogLevelInfo":     SetLogLevelInfo,
		"setLogLevelDebug":    SetLogLevelDebug,
		"setFabricDev":        SetFabricDev,
		"setFabricSandbox":    SetFabricSandbox,
		"setFabricProduction": SetFabricProduction,
		"setFabricLocal":      SetFabricLocal,
		"setFabric":           SetFabric,
		"application":         Application,
		"debug":               Debug,
		"info":                Info,
		"warn":                Warn,
		"error":               Error,
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

type Deferred interface {
	Resolve(...interface{})
	Reject(...interface{})
	Notify(...interface{})
	Promise() *js.Object
}

type deferred struct {
	this    *js.Object
	promise *js.Object
}

func Defer() Deferred {
	q := js.Global.Get("Q").Get("defer").Invoke()
	d := &deferred{
		this:    q,
		promise: q.Get("promise"),
	}

	return d
}

func (d *deferred) Resolve(args ...interface{}) {
	d.this.Get("resolve").Invoke(args...)
}

func (d *deferred) Reject(args ...interface{}) {
	d.this.Get("reject").Invoke(args...)
}

func (d *deferred) Notify(args ...interface{}) {
	d.this.Get("notify").Invoke(args...)
}

func (d *deferred) Promise() *js.Object {
	return d.promise
}

func (c *Conn) OnMessage(msg *js.Object) {
	c.app.ReceiveBytes([]byte(msg.String()))
}

func (c *Conn) OnOpen(msg *js.Object) {
	go c.domain.FinishJoin(c)
}

func (c *Conn) OnReopen(msg *js.Object) {
	c.app.SetState(core.Connected)
	c.app.SendHello()
}

func (c *Conn) OnClose(msg *js.Object) {
	c.app.ConnectionClosed("JS websocket closed")

	if c.app.ShouldReconnect() {
		go c.Reconnect()
	} else {
		if j := c.domain.wrapped.Get("onLeave"); j != js.Undefined {
			c.domain.wrapped.Call("onLeave", msg)
		}
	}
}

func (c *Conn) Reconnect() {
	delay := c.app.NextRetryDelay()
	time.Sleep(delay)

	factory := js.Global.Get("WsFactory").New(map[string]string{"type": "websocket", "url": core.Fabric})

	wsConn := factory.Call("create")
	c.wrapper = wsConn

	wsConn.Set("onmessage", c.OnMessage)
	wsConn.Set("onopen", c.OnReopen)
	wsConn.Set("onclose", c.OnClose)
}

func (c *Conn) Send(data []byte) error {
	c.wrapper.Call("send", string(data))

	// Added a nil error return
	// TOOD: the js connection can return its error for tranmission to the core as appropriate
	return nil
}

func (c *Conn) Close(reason string) error {
	core.Debug("Asked to close: ", reason)

	//TODO: Use appropriate error codes
	c.wrapper.Call("close", 1000, reason)
	return nil
}

func (c *Conn) SetApp(app core.App) {
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
	js.Global.Get("Renamer").Invoke(d.wrapped)
	return d.wrapped
}

func (d *Domain) Subdomain(name string) *js.Object {
	n := Domain{
		coreDomain: d.coreDomain.Subdomain(name),
		app:        d.app,
	}

	n.wrapped = js.MakeWrapper(&n)
	js.Global.Get("Renamer").Invoke(n.wrapped)
	return n.wrapped
}

func (d *Domain) LinkDomain(name string) *js.Object {
	n := Domain{
		coreDomain: d.coreDomain.LinkDomain(name),
		app:        d.app,
	}

	n.wrapped = js.MakeWrapper(&n)
	js.Global.Get("Renamer").Invoke(n.wrapped)
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
			yieldId := cb.Args[0].(uint64)

			// If the handler returns a promise, don't yeild! Wait until the
			// internal deferred resolves
			// core.Debug("Receive loop has object: %v", ret.String())

			// TODO: find the promises in a safer way, please
			if strings.Contains(ret.String(), "Promise") {

				// Closes over references so the final yield can be executed
				completeYield := func(result *js.Object) {
					core.Debug("Finishing deferred return")
					core.Debug("Finishing deferred return with id %d, args: %v", yieldId, result)
					a.conn.app.Yield(cb.Args[0].(uint64), []interface{}{result.Interface()})
				}
				errorYield := func(result *js.Object) {
					core.Debug("Finishing deferred return")
					core.Debug("Finishing deferred return with id %d, args: %v", yieldId, result)
					a.conn.app.YieldError(cb.Args[0].(uint64), "wamp.error.promise_rejection", []interface{}{result.Interface()})
				}

				// See riffle.js
				js.Global.Get("NestedInterceptor").Invoke(ret, completeYield, errorYield)
			} else {
				a.conn.app.Yield(cb.Args[0].(uint64), []interface{}{ret.Interface()})
			}
		}
	}
}

// Part 1 of the join-- start the join
func (d *Domain) Join() {
	factory := js.Global.Get("WsFactory").New(map[string]string{"type": "websocket", "url": core.Fabric})
	wsConn := factory.Call("create")

	conn := Conn{
		wrapper: wsConn,
		domain:  d,
		app:     d.coreDomain.GetApp(),
	}

	d.app.conn = conn

	wsConn.Set("onmessage", conn.OnMessage)
	wsConn.Set("onopen", conn.OnOpen)
	wsConn.Set("onclose", conn.OnClose)
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

//pass a token through to the core for authentication
func (d *Domain) SetToken(token string) {
	d.coreDomain.GetApp().SetToken(token)
}
func (d *Domain) GetToken() string {
	return d.coreDomain.GetApp().GetToken()
}

func (d *Domain) GetName() string {
	return d.coreDomain.GetName()
}

func (d *Domain) Login(user *js.Object) *js.Object {
	q := Defer()

	go func() {

		username := user.Get("username")
		password := user.Get("password")
		args := make([]string, 2)
		if username != js.Undefined {
			args[0] = strings.ToLower(username.String())
			if password != js.Undefined {
				args[1] = password.String()
			}
		}

		app := d.coreDomain.GetApp()

		if domain, err := app.Login(d.coreDomain, args...); err != nil {
			q.Reject(err.Error())
		} else {
			n := Domain{
				coreDomain: domain,
				app:        d.app,
			}

			n.wrapped = js.MakeWrapper(&n)
			js.Global.Get("Renamer").Invoke(n.wrapped)
			q.Resolve(n.wrapped)
		}
	}()

	return q.Promise()
}

func (d *Domain) RegisterAccount(user *js.Object) *js.Object {
	p := Defer()

	go func() {

		app := d.coreDomain.GetApp()
		username := user.Get("username")
		password := user.Get("password")
		email := user.Get("email")
		name := user.Get("name")
		if username == js.Undefined {
			p.Reject("Must provide username.")
			return
		}
		if password == js.Undefined {
			p.Reject("Must provide password.")
			return
		}
		if email == js.Undefined {
			p.Reject("Must provide email.")
			return
		}
		if name == js.Undefined {
			p.Reject("Must provide name.")
			return
		}

		if success, err := app.RegisterAccount(d.coreDomain, strings.ToLower(username.String()), password.String(), strings.ToLower(email.String()), name.String()); err != nil {
			p.Reject(err.Error())
		} else {
			if success {
				p.Resolve(nil)
			} else {
				p.Reject("Register Failed")
			}
		}
	}()

	return p.Promise()
}

func (d *Domain) Subscribe(endpoint string, handler *js.Object) *js.Object {
	cb := core.NewID()
	p := Defer()

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
			p.Reject(err.Error())
		}
	}()

	return p.Promise()
}

func (d *Domain) Register(endpoint string, handler *js.Object) *js.Object {
	cb := core.NewID()
	p := Defer()

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
			p.Reject(err.Error())
		}
	}()

	return p.Promise()
}

func typeChecker(types []interface{}, results []interface{}, deferred *js.Object) {
	err := core.SoftCumin(types, results)
	if err != nil {
		deferred.Call("reject", err.Error())
	} else {
		deferred.Call("resolve", results...)
	}
}

func (d *Domain) Call(endpoint string, args ...interface{}) *js.Object {
	p := Defer()

	go func() {
		if results, err := d.coreDomain.Call(endpoint, args); err == nil {
			p.Resolve(results...)
		} else {
			p.Reject(err.Error())
		}
	}()

	p.Promise().Set("want", js.Global.Get("WantInterceptor").Invoke(p.Promise(), typeChecker))

	return p.Promise()
}

func (d *Domain) Publish(endpoint string, args ...interface{}) *js.Object {
	return promisify(func() (interface{}, error) { return nil, d.coreDomain.Publish(endpoint, args) })
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

func (d *Domain) CallExpects(cb uint64, types []interface{}) {
	d.coreDomain.CallExpects(cb, types)
}

// Turn the given invocation into a JS promise. If the function returns an error, return the error,
// else return the results of the function
func promisify(fn func() (interface{}, error)) *js.Object {
	p := Defer()

	go func() {
		if results, err := fn(); err == nil {
			core.Info("Resolving the promise with results: %s", results)
			p.Resolve(results)
		} else {
			p.Reject(err.Error())
		}
	}()

	return p.Promise()
}

func SetLogLevelOff()   { core.LogLevel = core.LogLevelOff }
func SetLogLevelApp()   { core.LogLevel = core.LogLevelApp }
func SetLogLevelErr()   { core.LogLevel = core.LogLevelErr }
func SetLogLevelWarn()  { core.LogLevel = core.LogLevelWarn }
func SetLogLevelInfo()  { core.LogLevel = core.LogLevelInfo }
func SetLogLevelDebug() { core.LogLevel = core.LogLevelDebug }

func SetFabricDev() {
	core.Fabric = core.FabricDev
	core.Registrar = core.RegistrarDev
}

func SetFabricProduction() {
	core.Fabric = core.FabricProduction
	core.Registrar = core.RegistrarProduction
}

func SetFabricLocal() {
	core.Fabric = core.FabricLocal
	core.Registrar = core.RegistrarLocal
}

func SetFabricSandbox()       { core.Fabric = core.FabricSandbox }
func SetFabric(url string)    { core.Fabric = url }
func SetRegistrar(url string) { core.Registrar = url }

func Application(s string) { core.Application("%s", s) }
func Debug(s string)       { core.Debug("%s", s) }
func Info(s string)        { core.Info("%s", s) }
func Warn(s string)        { core.Warn("%s", s) }
func Error(s string)       { core.Error("%s", s) }

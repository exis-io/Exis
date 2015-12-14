// package name: riffle
package main

import (
	"C"
	"unsafe"

	"github.com/exis-io/core"
	"github.com/exis-io/core/goRiffle"
)

// Required main method
func main() {}

// By default always connect to the production fabric at node.exis.io
var fabric string = core.FabricProduction

//export CBID
func CBID() uint {
	return core.NewID()
}

//export NewDomain
func NewDomain(name *C.char) unsafe.Pointer {
	d := core.NewDomain(C.GoString(name), nil)
	return unsafe.Pointer(&d)
}

//export Subdomain
func Subdomain(pdomain unsafe.Pointer, name *C.char) unsafe.Pointer {
	d := *(*core.Domain)(pdomain)
	n := d.Subdomain(C.GoString(name))
	return unsafe.Pointer(&n)
}

//export Receive
func Receive(pdomain unsafe.Pointer) []byte {
	d := *(*core.Domain)(pdomain)
	return []byte(core.MantleMarshall(d.GetApp().CallbackListen()))
}

//export Join
func Join(pdomain unsafe.Pointer, cb uint, eb uint) {
	d := *(*core.Domain)(pdomain)

	if c, err := goRiffle.Open(fabric); err != nil {
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		if err := d.Join(c); err != nil {
			d.GetApp().CallbackSend(eb, err.Error())
		} else {
			d.GetApp().CallbackSend(cb)
		}
	}
}

//export Subscribe
func Subscribe(pdomain unsafe.Pointer, cb uint, endpoint *C.char) {
	d := *(*core.Domain)(pdomain)
	go func() {
		d.Subscribe(C.GoString(endpoint), cb, make([]interface{}, 0))
	}()
}

//export Register
func Register(pdomain unsafe.Pointer, cb uint, endpoint *C.char) {
	d := *(*core.Domain)(pdomain)
	go func() {
		d.Register(C.GoString(endpoint), cb, make([]interface{}, 0))
	}()
}

//export Publish
func Publish(pdomain unsafe.Pointer, cb uint, endpoint *C.char, args *C.char) {
	d := *(*core.Domain)(pdomain)
	go func() {
		d.Publish(C.GoString(endpoint), cb, core.MantleUnmarshal(C.GoString(args)))
	}()
}

//export Call
func Call(pdomain unsafe.Pointer, cb uint, endpoint *C.char, args *C.char) {
	d := *(*core.Domain)(pdomain)
	go func() {
		d.Call(C.GoString(endpoint), cb, core.MantleUnmarshal(C.GoString(args)))
	}()
}

//export Yield
func Yield(pdomain unsafe.Pointer, request uint, args *C.char) {
	d := *(*core.Domain)(pdomain)
	go func() {
		d.GetApp().Yield(request, core.MantleUnmarshal(C.GoString(args)))
	}()
}

//export Unsubscribe
func Unsubscribe(pdomain unsafe.Pointer, endpoint *C.char) {
	d := *(*core.Domain)(pdomain)
	go func() {
		d.Unsubscribe(C.GoString(endpoint))
	}()
}

//export Unregister
func Unregister(pdomain unsafe.Pointer, endpoint *C.char) {
	d := *(*core.Domain)(pdomain)
	go func() {
		d.Unregister(C.GoString(endpoint))
	}()
}

//export Leave
func Leave(pdomain unsafe.Pointer) {
	d := *(*core.Domain)(pdomain)
	go func() {
		d.Leave()
	}()
}

//export SetLogLevelOff
func SetLogLevelOff() { core.LogLevel = core.LogLevelOff }

//export SetLogLevelApp
func SetLogLevelApp() { core.LogLevel = core.LogLevelApp }

//export SetLogLevelErr
func SetLogLevelErr() { core.LogLevel = core.LogLevelErr }

//export SetLogLevelWarn
func SetLogLevelWarn() { core.LogLevel = core.LogLevelWarn }

//export SetLogLevelInfo
func SetLogLevelInfo() { core.LogLevel = core.LogLevelInfo }

//export SetLogLevelDebug
func SetLogLevelDebug() { core.LogLevel = core.LogLevelDebug }

//export SetFabricDev
func SetFabricDev() { fabric = core.FabricDev }

//export SetFabricSandbox
func SetFabricSandbox() { fabric = core.FabricSandbox }

//export SetFabricProduction
func SetFabricProduction() { fabric = core.FabricProduction }

//export SetFabricLocal
func SetFabricLocal() { fabric = core.FabricLocal }

//export SetFabric
func SetFabric(url string) { fabric = url }

//export Application
func Application(s string) { core.Application("%s", s) }

//export Debug
func Debug(s string) { core.Debug("%s", s) }

//export Info
func Info(s string) { core.Info("%s", s) }

//export Warn
func Warn(s string) { core.Warn("%s", s) }

//export Error
func Error(s string) { core.Error("%s", s) }

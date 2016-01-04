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

//export CBID
func CBID() uint64 {
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
func Join(pdomain unsafe.Pointer, cb uint64, eb uint64) {
	d := *(*core.Domain)(pdomain)

	if c, err := goRiffle.Open(core.Fabric); err != nil {
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
func Subscribe(pdomain unsafe.Pointer, endpoint *C.char, cb uint64, eb uint64, hn uint64, types *C.char) {
	d := *(*core.Domain)(pdomain)
	go core.MantleSubscribe(d, C.GoString(endpoint), cb, eb, hn, core.MantleUnmarshal(C.GoString(types)))
}

//export Register
func Register(pdomain unsafe.Pointer, endpoint *C.char, cb uint64, eb uint64, hn uint64, types *C.char) {
	d := *(*core.Domain)(pdomain)
	go core.MantleRegister(d, C.GoString(endpoint), cb, eb, hn, core.MantleUnmarshal(C.GoString(types)))
}

//export Publish
func Publish(pdomain unsafe.Pointer, endpoint *C.char, cb uint64, eb uint64, args *C.char) {
	d := *(*core.Domain)(pdomain)
	go core.MantlePublish(d, C.GoString(endpoint), cb, eb, core.MantleUnmarshal(C.GoString(args)))
}

//export Call
func Call(pdomain unsafe.Pointer, endpoint *C.char, cb uint64, eb uint64, args *C.char, types *C.char) {
	d := *(*core.Domain)(pdomain)
	go core.MantleCall(d, C.GoString(endpoint), cb, eb, core.MantleUnmarshal(C.GoString(args)), core.MantleUnmarshal(C.GoString(types)))
}

//export Yield
func Yield(pdomain unsafe.Pointer, request uint64, args *C.char) {
	d := *(*core.Domain)(pdomain)
	go d.GetApp().Yield(request, core.MantleUnmarshal(C.GoString(args)))
}

//export Unsubscribe
func Unsubscribe(pdomain unsafe.Pointer, endpoint *C.char, cb uint64, eb uint64) {
	d := *(*core.Domain)(pdomain)
	go core.MantleUnsubscribe(d, C.GoString(endpoint), cb, eb)
}

//export Unregister
func Unregister(pdomain unsafe.Pointer, endpoint *C.char, cb uint64, eb uint64) {
	d := *(*core.Domain)(pdomain)
	go core.MantleUnregister(d, C.GoString(endpoint), cb, eb)
}

//export Leave
func Leave(pdomain unsafe.Pointer) {
	d := *(*core.Domain)(pdomain)
	go d.Leave()
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
func SetFabricDev() { core.Fabric = core.FabricDev }

//export SetFabricSandbox
func SetFabricSandbox() { core.Fabric = core.FabricSandbox }

//export SetFabricProduction
func SetFabricProduction() { core.Fabric = core.FabricProduction }

//export SetFabricLocal
func SetFabricLocal() { core.Fabric = core.FabricLocal }

//export MantleSetFabric
func MantleSetFabric(url *C.char) { core.Fabric = C.GoString(url) }

//export Application
func Application(s *C.char) { core.Application("%s", C.GoString(s)) }

//export Debug
func Debug(s *C.char) { core.Debug("%s", C.GoString(s)) }

//export Info
func Info(s *C.char) { core.Info("%s", C.GoString(s)) }

//export Warn
func Warn(s *C.char) { core.Warn("%s", C.GoString(s)) }

//export Error
func Error(s *C.char) { core.Error("%s", C.GoString(s)) }

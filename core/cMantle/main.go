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
func Call(pdomain unsafe.Pointer, endpoint *C.char, cb uint64, eb uint64, args *C.char) {
	d := *(*core.Domain)(pdomain)
	go core.MantleCall(d, C.GoString(endpoint), cb, eb, core.MantleUnmarshal(C.GoString(args)))
}

//export Yield
func Yield(pdomain unsafe.Pointer, request uint64, args *C.char) {
	d := *(*core.Domain)(pdomain)
	go d.GetApp().Yield(request, core.MantleUnmarshal(C.GoString(args)))
}

//export CallExpects
func CallExpects(pdomain unsafe.Pointer, cb uint64, types *C.char) {
	d := *(*core.Domain)(pdomain)
	go d.CallExpects(cb, core.MantleUnmarshal(C.GoString(types)))
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

//export MantleSetLogLevelOff
func MantleSetLogLevelOff() { core.LogLevel = core.LogLevelOff }

//export MantleSetLogLevelApp
func MantleSetLogLevelApp() { core.LogLevel = core.LogLevelApp }

//export MantleSetLogLevelErr
func MantleSetLogLevelErr() { core.LogLevel = core.LogLevelErr }

//export MantleSetLogLevelWarn
func MantleSetLogLevelWarn() { core.LogLevel = core.LogLevelWarn }

//export MantleSetLogLevelInfo
func MantleSetLogLevelInfo() { core.LogLevel = core.LogLevelInfo }

//export MantleSetLogLevelDebug
func MantleSetLogLevelDebug() { core.LogLevel = core.LogLevelDebug }

//export MantleSetFabricDev
func MantleSetFabricDev() {
    core.Fabric = core.FabricDev
    core.Registrar = core.RegistrarDev
}

//export MantleSetFabricSandbox
func MantleSetFabricSandbox() { core.Fabric = core.FabricSandbox }

//export MantleSetFabricProduction
func MantleSetFabricProduction() {
    core.Fabric = core.FabricProduction
    core.Registrar = core.RegistrarProduction
}

//export MantleSetFabricLocal
func MantleSetFabricLocal() {
    core.Fabric = core.FabricLocal
    core.Registrar = core.RegistrarLocal
}

//export MantleSetFabric
func MantleSetFabric(url *C.char) { core.Fabric = C.GoString(url) }

//export MantleSetRegistrar
func MantleSetRegistrar(url *C.char) { core.Registrar = C.GoString(url) }

//export MantleApplication
func MantleApplication(s *C.char) { core.Application("%s", C.GoString(s)) }

//export MantleDebug
func MantleDebug(s *C.char) { core.Debug("%s", C.GoString(s)) }

//export MantleInfo
func MantleInfo(s *C.char) { core.Info("%s", C.GoString(s)) }

//export MantleWarn
func MantleWarn(s *C.char) { core.Warn("%s", C.GoString(s)) }

//export MantleError
func MantleError(s *C.char) { core.Error("%s", C.GoString(s)) }


//export MantleSetCuminStrict
func MantleSetCuminStrict() { core.CuminLevel = core.CuminStrict }

//export MantleSetCuminLoose
func MantleSetCuminLoose() { core.CuminLevel = core.CuminLoose }

//export MantleSetCuminOff
func MantleSetCuminOff() { core.CuminLevel = core.CuminOff }


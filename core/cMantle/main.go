// package name: riffle
package main

import (
	"C"

	"github.com/exis-io/core"
	"github.com/exis-io/core/shared"
)

// Required main method
func main() {}

//export CBID
func CBID() uint64 {
	return core.NewID()
}

// Note that with go 1.6 we can't pass pointers back up through the language boundrary.
// An "unsafe" implementation is going to fail, since the go GC is going to have a bad time.

// So yet another messaging bus. Make sure to destroy domains in the crust on their deinit

var domainIndex = make(map[uint64]core.Domain)
var coreModel core.Model

// This is bad and should be moved-- here for testing initial model object implementation
// Used with the model interface to access the top level connection, assigned (and reassigned!)
// when NewDomain is called
var appDomain core.Domain

//export Free
func Free(pdomain uint64) {
	delete(domainIndex, pdomain)
}

//export NewDomain
func NewDomain(name *C.char) uint64 {
	i := CBID()
	d := core.NewDomain(C.GoString(name), nil)
    appDomain = d
	domainIndex[i] = d
	return i
}

//export Subdomain
func Subdomain(pdomain uint64, name *C.char) uint64 {
	d := get(pdomain)
	i := CBID()
	domainIndex[i] = d.Subdomain(C.GoString(name))
	return i
}

//export SetToken
func SetToken(pdomain uint64, token *C.char) {
	d := get(pdomain)
	d.GetApp().SetToken(C.GoString(token))
}

//export Receive
func Receive(dptr uint64) *C.char {
	// Used to be a byte slice, but 1.6 cgo checks will not allow that
	d := get(dptr)
	return C.CString(core.MantleMarshall(d.GetApp().CallbackListen()))
}

//export Join
func Join(pdomain uint64, cb uint64, eb uint64) {
	d := get(pdomain)

	if c, err := shared.Open(core.Fabric); err != nil {
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
func Subscribe(pdomain uint64, endpoint *C.char, cb uint64, eb uint64, hn uint64, types *C.char, options *C.char) {
	d := get(pdomain)
	go core.MantleSubscribe(d, C.GoString(endpoint), cb, eb, hn, core.MantleUnmarshal(C.GoString(types)), core.MantleUnmarshalMap(C.GoString(options)))
}

//export Register
func Register(pdomain uint64, endpoint *C.char, cb uint64, eb uint64, hn uint64, types *C.char, options *C.char) {
	d := get(pdomain)
	go core.MantleRegister(d, C.GoString(endpoint), cb, eb, hn, core.MantleUnmarshal(C.GoString(types)), core.MantleUnmarshalMap(C.GoString(options)))
}

//export Publish
func Publish(pdomain uint64, endpoint *C.char, cb uint64, eb uint64, args *C.char, options *C.char) {
	d := get(pdomain)
	go core.MantlePublish(d, C.GoString(endpoint), cb, eb, core.MantleUnmarshal(C.GoString(args)), core.MantleUnmarshalMap(C.GoString(options)))
}

//export Call
func Call(pdomain uint64, endpoint *C.char, cb uint64, eb uint64, args *C.char, options *C.char) {
	d := get(pdomain)
	go core.MantleCall(d, C.GoString(endpoint), cb, eb, core.MantleUnmarshal(C.GoString(args)), core.MantleUnmarshalMap(C.GoString(options)))
}

//export Yield
func Yield(pdomain uint64, request uint64, args *C.char) {
	d := get(pdomain)
	go d.GetApp().Yield(request, core.MantleUnmarshal(C.GoString(args)))
}

//export CallExpects
func CallExpects(pdomain uint64, cb uint64, types *C.char) {
	d := get(pdomain)
	go d.CallExpects(cb, core.MantleUnmarshal(C.GoString(types)))
}

//export Unsubscribe
func Unsubscribe(pdomain uint64, endpoint *C.char, cb uint64, eb uint64) {
	d := get(pdomain)
	go core.MantleUnsubscribe(d, C.GoString(endpoint), cb, eb)
}

//export Unregister
func Unregister(pdomain uint64, endpoint *C.char, cb uint64, eb uint64) {
	d := get(pdomain)
	go core.MantleUnregister(d, C.GoString(endpoint), cb, eb)
}

//export Leave
func Leave(pdomain uint64) {
	d := get(pdomain)
	go d.Leave()
}

func get(i uint64) core.Domain {
	// get the domain from the domain index
	if d, ok := domainIndex[i]; !ok {
		return nil
	} else {
		return d
	}
}

// Model Operations

//export ModelAll
func ModelAll(cb uint64, eb uint64, collection *C.char, query *C.char) {
	go core.MantleModel(appDomain, coreModel.All, C.GoString(collection), core.MantleUnmarshalMap(C.GoString(query)), cb, eb)
}

//export ModelFind
func ModelFind(cb uint64, eb uint64, collection *C.char, query *C.char) {
	go core.MantleModel(appDomain, coreModel.Find, C.GoString(collection), core.MantleUnmarshalMap(C.GoString(query)), cb, eb)
}

//export ModelCreate
func ModelCreate(cb uint64, eb uint64, collection *C.char, query *C.char) {
	go core.MantleModel(appDomain, coreModel.Create, C.GoString(collection), core.MantleUnmarshalMap(C.GoString(query)), cb, eb)
}

//export ModelSave
func ModelSave(cb uint64, eb uint64, collection *C.char, query *C.char) {
	go core.MantleModel(appDomain, coreModel.Save, C.GoString(collection), core.MantleUnmarshalMap(C.GoString(query)), cb, eb)
}

//export ModelCount
func ModelCount(cb uint64, eb uint64, collection *C.char, query *C.char) {
	go core.MantleModel(appDomain, coreModel.Count, C.GoString(collection), core.MantleUnmarshalMap(C.GoString(query)), cb, eb)
}

// Logging and general Utils

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

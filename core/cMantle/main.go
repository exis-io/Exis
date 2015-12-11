// package name: riffle
package riffle

import (
	"C"
	"unsafe"

	"github.com/exis-io/core"
	"github.com/exis-io/core/goRiffle"
)

//export main
// func main() {}

// By default always connect to the production fabric at node.exis.io
var fabric string = core.FabricProduction

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
func Receive(pdomain unsafe.Pointer) string {
	d := *(*core.Domain)(pdomain)
	return core.MantleMarshall(d.GetApp().CallbackListen())
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

// Bytes for args!
//export Publish
func Publish(pdomain unsafe.Pointer, cb uint, endpoint *C.char, args []byte) {
	d := *(*core.Domain)(pdomain)
	go func() {
		d.Publish(C.GoString(endpoint), cb, core.MantleUnmarshal(string(args)))
	}()
}

//export Call
func Call(pdomain unsafe.Pointer, cb uint, endpoint *C.char, args []byte) {
	d := *(*core.Domain)(pdomain)
	go func() {
		d.Call(C.GoString(endpoint), cb, core.MantleUnmarshal(string(args)))
	}()
}

//export Yield
func Yield(pdomain unsafe.Pointer, request uint, args []byte) {
	d := *(*core.Domain)(pdomain)
	go func() {
		d.GetApp().Yield(request, core.MantleUnmarshal(string(args)))
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

// //export Subscribe
// func Subscribe(pdomain unsafe.Pointer, endpoint *C.char, data []bytes) []byte {
// 	d := *(*core.Domain)(pdomain)
// 	return coreInvoke(d.Subscribe, endpoint, unmarshall(data))
// }

// //export Register
// func Register(pdomain unsafe.Pointer, endpoint *C.char, data []byte) []byte {
// 	d := *(*core.Domain)(pdomain)
// 	return coreInvoke(d.Register, endpoint, unmarshall(data))
// }

// //export Publish
// func Publish(pdomain unsafe.Pointer, endpoint *C.char, data []byte) []byte {
// 	d := *(*core.Domain)(pdomain)
// 	return coreInvoke(d.Publish, endpoint, unmarshall(data))
// }

// //export Call
// func Call(pdomain unsafe.Pointer, endpoint *C.char, data []byte) []byte {
// 	d := *(*core.Domain)(pdomain)
// 	return coreInvoke(d.Call, endpoint, unmarshall(data))
// }

// // Accepts a domain operator function, a list of any arguments, and an endpoint. Performs the operation on the given domain.
// func coreInvoke(operation func(string, uint, []interface{}) error, endpoint *C.char, args []interface{}) []byte {
// 	cb, eb := core.NewID(), core.NewID()
// 	go func() {
// 		if err := operation(C.GoString(C.GoString(endpoint)), cb, args); err != nil {
// 			man.InvokeError(eb, err.Error())
// 		}
// 	}()
// 	return marshall([]uint{cb, eb})
// }

// //export Yield
// func Yield(args []byte) {
// 	// What to pass in as the id?

// 	// This needs work
// 	// core.Yield(C.GoString(e))
// }

// //export Unsubscribe
// func Unsubscribe(pdomain unsafe.Pointer, e *C.char) {
// 	d := *(*core.Domain)(pdomain)
// 	d.Unsubscribe(C.GoString(e))
// }

// //export Unregister
// func Unregister(pdomain unsafe.Pointer, e *C.char) {
// 	d := *(*core.Domain)(pdomain)
// 	d.Unregister(C.GoString(e))
// }

// //export Join
// func Join(pdomain unsafe.Pointer) []byte {
// 	d := *(*core.Domain)(pdomain)
// 	cb, eb := core.NewID(), core.NewID()

// 	go func() {
// 		if man.conn != nil {
// 			man.InvokeError(eb, "Connection is already open!")
// 		}

// 		if c, err := goRiffle.Open(man.fabric); err != nil {
// 			man.InvokeError(eb, err.Error())
// 		} else {
// 			man.conn = c
// 			c.App = man.app

// 			if err := d.Join(c); err != nil {
// 				core.Warn("Unable to join! %s", err)
// 				man.InvokeError(eb, err.Error())
// 			} else {
// 				core.Info("Joined!")
// 				man.Invoke(cb, nil)
// 			}
// 		}
// 	}()

// 	return marshall([]uint{cb, eb})
// }

// //export Leave
// func Leave(pdomain unsafe.Pointer) {
// 	d := *(*core.Domain)(pdomain)
// 	d.Leave()
// }

// //export Recieve
// func Recieve() []byte {
// 	data := <-man.recv
// 	return data
// }

// func marshall(data interface{}) []byte {
// 	if r, e := json.Marshal(data); e == nil {
// 		return r
// 	} else {
// 		fmt.Println("Unable to marshall data!")
// 		return nil
// 	}
// }

// func unmarshall(data []byte) []interface{} {
// 	var ret []interface{}
// 	if err := json.Unmarshal(data, &ret); err != nil {
// 		// Handle this error a little more gracefully, eh?
// 		core.Warn("Unable to unmarshall call from crust! %s", data)
// 		return nil
// 	} else {
// 		return ret
// 	}
// }

// // Unexported Functions
// func (m mantle) Invoke(id uint, args []interface{}) {
// 	core.Debug("Invoke called: ", id, args)
// 	// man.recv <- marshall(map[string]interface{}{"0": id, "1": args})
// 	man.recv <- marshall([]interface{}{id, args})
// }

// func (m mantle) InvokeError(id uint, e string) {
// 	// core.Debug("Invoking error: ", id, e)
// 	s := fmt.Sprintf("Err: %s", e)
// 	man.recv <- marshall([]interface{}{id, s})
// }

// func (m mantle) OnJoin(string) {
// 	fmt.Println("Domain joined!")
// }

// func (m mantle) OnLeave(string) {
// 	fmt.Println("Domain left!")
// }

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

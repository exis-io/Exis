// package name: riffle
package main

import (
	"C"
	"encoding/json"
	"fmt"
	"unsafe"

	"github.com/exis-io/core"
	"github.com/exis-io/core/goRiffle"
)

/*
This is the lowest level core, just exposes the C API. Used for python, swift-linux, and osx.

You are responsible for cleaning up C references!


Every function here is reactive: it returns two indicies to callbacks to be triggered later.

Reg, Sub, Pub, Call all return indicies to callbacks they will later call.
*/

type mantle struct {
	app  core.App
	conn *goRiffle.WebsocketConnection
	recv chan []byte
    fabric string
}

var man = &mantle{
	recv: make(chan []byte),
    fabric: core.ProudctionFabric,
}

// Required main method
func main() {}

//export NewDomain
func NewDomain(name *C.char) unsafe.Pointer {
	if man.app == nil {
		man.app = core.NewApp()
	}

	d := man.app.NewDomain(C.GoString(name), man)
	return unsafe.Pointer(&d)
}

//export Subscribe
func Subscribe(pdomain unsafe.Pointer, endpoint *C.char) []byte {
	d := *(*core.Domain)(pdomain)
	cb, eb := core.NewID(), core.NewID()

	go func() {
		d.Subscribe(C.GoString(endpoint), cb, make([]interface{}, 0))
	}()

	return marshall([]uint{cb, eb})
}

//export Register
func Register(pdomain unsafe.Pointer, endpoint *C.char) []byte {
	d := *(*core.Domain)(pdomain)
	cb, eb := core.NewID(), core.NewID()

	go func() {
		// Catch errors and erback here
		d.Register(C.GoString(endpoint), cb, make([]interface{}, 0))
	}()

	return marshall([]uint{cb, eb})
}

//export Publish
func Publish(pdomain unsafe.Pointer, endpoint *C.char) {
	d := *(*core.Domain)(pdomain)
	cb, _ := core.NewID(), core.NewID()

	go func() {
		d.Publish(C.GoString(endpoint), cb, make([]interface{}, 0))
	}()
}

//export Call
func Call(pdomain unsafe.Pointer, endpoint *C.char) {
	d := *(*core.Domain)(pdomain)
	cb, _ := core.NewID(), core.NewID()

	go func() {
		d.Call(C.GoString(endpoint), cb, make([]interface{}, 0))
	}()
}

// func coreInvoke(operation func(string, uint, []interface{}), endpoint *C.char) []byte {
// 	cb, eb := core.NewID(), core.NewID()

// 	go func() {
// 		// Catch errors and erback here
// 		operation(C.GoString(endpoint), cb, make([]interface{}, 0))
// 	}()

// 	return marshall([]uint{cb, eb})
// }

//export Yield
func Yield(args []byte) {
	// This needs work
	// core.Yield(C.GoString(e))
}

//export Unsubscribe
func Unsubscribe(pdomain unsafe.Pointer, e *C.char) {
	d := *(*core.Domain)(pdomain)
	d.Unsubscribe(C.GoString(e))
}

//export Unregister
func Unregister(pdomain unsafe.Pointer, e *C.char) {
	d := *(*core.Domain)(pdomain)
	d.Unregister(C.GoString(e))
}

//export Join
func Join(pdomain unsafe.Pointer) []byte {
	d := *(*core.Domain)(pdomain)
	cb, eb := core.NewID(), core.NewID()

	go func() {
		if man.conn != nil {
			man.InvokeError(eb, "Connection is already open!")
		}

		if c, err := goRiffle.Open(man.fabric); err != nil {
			man.InvokeError(eb, err.Error())
		} else {
			man.conn = c
			c.App = man.app

			if err := d.Join(c); err != nil {
				core.Warn("Unable to join! %s", err)
				man.InvokeError(eb, err.Error())
			} else {
				core.Info("Joined!")
				man.Invoke(cb, nil)
			}
		}
	}()

	return marshall([]uint{cb, eb})
}

//export Leave
func Leave(pdomain unsafe.Pointer) {
	d := *(*core.Domain)(pdomain)
	d.Leave()
}

//export Recieve
func Recieve() []byte {
	data := <-man.recv
	return data
}

func marshall(data interface{}) []byte {
	if r, e := json.Marshal(data); e == nil {
		return r
	} else {
		fmt.Println("Unable to marshall data!")
		return nil
	}
}

func unmarshall() {

}

// Unexported Functions
func (m mantle) Invoke(id uint, args []interface{}) {
	core.Debug("Invoke called: ", id, args)
	// man.recv <- marshall(map[string]interface{}{"0": id, "1": args})
	man.recv <- marshall([]interface{}{id, args})
}

func (m mantle) InvokeError(id uint, e string) {
	// core.Debug("Invoking error: ", id, e)
	s := fmt.Sprintf("Err: %s", e)
	man.recv <- marshall([]interface{}{id, s})
}

func (m mantle) OnJoin(string) {
	fmt.Println("Domain joined!")
}

func (m mantle) OnLeave(string) {
	fmt.Println("Domain left!")
}

//export SetLoggingLevel
func SetLoggingLevel(l int) {
	core.LogLevel = l
}

//export SetLogLevelErr
func SetLogLevelErr() {
    core.LogLevel = core.LogLevelErr
}

//export SetLogLevelWarn
func SetLogLevelWarn() {
    core.LogLevel = core.LogLevelWarn
}

//export SetLogLevelInfo
func SetLogLevelInfo() {
    core.LogLevel = core.LogLevelInfo
}

//export SetLogLevelDebug
func SetLogLevelDebug() {
    core.LogLevel = core.LogLevelDebug
}

//export SetDevFabric
func SetDevFabric() {
    man.fabric = core.DevFabric
}

//export SetSandboxFabric
func SetSandboxFabric() {
    man.fabric = core.SandboxFabric
}

//export SetProductionFabric
func SetProductionFabric() {
    man.fabric = core.ProudctionFabric
}

//export SetLocalFabric
func SetLocalFabric() {
    man.fabric = core.ProudctionFabric
}

//export SetCustomFabric
func SetCustomFabric(url *C.char) {
    man.fabric = C.GoString(url)
}



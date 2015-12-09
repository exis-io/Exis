// package name: riffle
package main

import (
	"C"
    "fmt"
    "unsafe"

	"github.com/exis-io/core"
	"github.com/exis-io/core/goRiffle"
)

/*
This is the lowest level core, just exposes the C API. Used for python, swift-linux, and osx.

You are responsible for cleaning up C references!


Every function here is reactive: it returns two indicies to callbacks to be triggered later.
*/


type mantle struct {
	app   core.App
	conn *goRiffle.WebsocketConnection
}

var man = new(mantle)

// Required main method
func main() {}

//export NewDomain
func NewDomain(name *C.char) unsafe.Pointer {
	// Return the address of the domain (?)

	if man.app == nil {
		man.app = core.NewApp()
	}

	d := man.app.NewDomain(C.GoString(name), man)

    return unsafe.Pointer(&d)
}


//export Subscribe
func Subscribe(pdomain unsafe.Pointer, domain *C.char)  {
    d := *(*core.Domain)(pdomain)
	d.Subscribe(C.GoString(domain))
    
    // call function in a goroutine, immediately return the id of the call?
    // Something like:
    /* 
    good, bad := makeIds

    go func() {
        if err = Subscribe(endpoint, good); err != nil {
            Invoke(errback)
        }
    }()

    return good, bad

    */
}

//export Register
func Register(pdomain unsafe.Pointer, domain *C.char)  {
    d := *(*core.Domain)(pdomain)
	d.Register(C.GoString(domain))
}

//export Yield
func Yield(args []byte) {
    core.Yield(C.GoString(e))
}

//export Publish
func Publish(pdomain unsafe.Pointer, e *C.char) {
    d := *(*core.Domain)(pdomain)
    d.Publish(C.GoString(e))
}

//export Call
func Call(pdomain unsafe.Pointer, e *C.char) {
    d := *(*core.Domain)(pdomain)
    d.Call(C.GoString(e))
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
func Join(pdomain unsafe.Pointer) {
    d := *(*core.Domain)(pdomain)
    
    if man.conn != nil {
        fmt.Println("Connection is already open!")
    }

    if c, err := goRiffle.Open(core.SandboxFabric); err != nil {
        core.Warn("Unable to open connection! Err: %s", err.Error())
    } else {
        man.conn = c
        d.Join(c)
    }
}

//export Leave
func Leave(pdomain unsafe.Pointer, ) {
    d := *(*core.Domain)(pdomain)
    d.Leave()
}


// Unexported Functions
func (m mantle) Invoke(id uint, args []interface{}) ([]interface{}, error) {
    fmt.Println("Invoke called: ", id, args)
    return make([]interface{}, 0), nil
}

func (m mantle) OnJoin(string) {
    fmt.Println("Domain joined!")
}

func (m mantle) OnLeave(string) {
    fmt.Println("Domain left!")
}

// export Hello
// func Hello(pdomain unsafe.Pointer) {
//     // Testing returning go callbacks into the C bridge
//     d := *(*domain)(pdomain)
//     d.hello()
// }

// func (d *domain) hello() {
//     fmt.Println(d.name + " called from swift!")
// }



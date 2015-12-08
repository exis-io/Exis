// package name: riffle
package main

import (
	"C"

	"github.com/exis-io/core"
	"github.com/exis-io/core/goRiffle"
)

/*
This is the lowest level core, just exposes the C API. Used for python, swift-linux, and osx.

You are responsible for cleaning up C references!


Every function here is reactive: it returns two indicies to callbacks to be triggered later.
*/

import "C"
import "fmt"

type mantle struct {
	app   core.App
	connn *goRiffle.WebsocketConnection
}

var man = new(mantle)

// Required main method
func main() {}

//export NewDomain
func NewDomain(name *C.char) {
	// Return the address of the domain (?)

	if man.app == nil {
		man.app = core.NewApp()
	}

	man.app.NewDomain(C.GoString(name), man)
}

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

// we store it in a global variable so that the garbage collector
// doesn't clean up the memory for any temporary variables created.
// var MyCallbackFunc = MyCallback

// func Example() {
// 	C.CallMyFunction(unsafe.Pointer(&MyCallbackFunc))
// }

// //export Subscribe
// func Subscribe(domain *C.char) []byte {
// 	return core.PSubscribe(C.GoString(domain))
// }

// //export Recieve
// func Recieve() []byte {
// 	return core.PRecieve()
// }

// //export Yield
// func Yield(args []byte) {
// 	core.PYield(args)
// }

// //export Register
// func Register(domain *C.char) []byte {
// 	return core.PRegister(C.GoString(domain))
// }

// //export Test
// func Test() int {
// 	fmt.Println("Entering test")
// 	go spin()
// 	return 1
// }

// func spin() {
// 	fmt.Println("Starting")
// 	sum := 1
// 	for sum < 1000 {
// 		sum += sum
// 		fmt.Println(sum)
// 	}
// }

// //export go_callback_int
// func go_callback_int(pfoo unsafe.Pointer, p1 C.int) {
//     // Testing returning go callbacks into the C bridge
//     foo := *(*func(C.int))(pfoo)
//     foo(p1)
// }

// func MyCallback(x C.int) {
//     fmt.Println("callback with", x)
// }

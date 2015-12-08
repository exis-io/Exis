// package name: riffle
package main

// This is the lowest level core, it just exposes the C API
// Used for python, swift-linux, and osx

import (
	"C"

	"github.com/exis-io/core"
)

// Required main method
func main() {}

//export Test
func Test() {
	core.Info("Server starting")
	// core.SetLoggingDebug()

	// a := core.NewDomain("xs.damouse.alpha")
	// a.Join()

	// e := a.Subscribe("sub", func() {
	// 	core.Info("Pub received!")
	// })

	// if e != nil {
	// 	core.Info("Unable to subscribe: ", e.Error())
	// }

	// e = a.Register("reg", func() {
	// 	core.Info("Call received!")
	// })

	// if e != nil {
	// 	core.Info("Unable to subscribe: ", e.Error())
	// }

	// // Run the client until Leave is called
	// a.Run()
}

// // Required main method
// func main() {}

// //export Connector
// func Connector(url *C.char, domain *C.char) *C.char {
// 	ret := core.PConnector(C.GoString(url), C.GoString(domain))
// 	return C.CString(ret)
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

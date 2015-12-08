// package name: riffle
package main

// This is the lowest level core, it just exposes the C API
// Used for python, swift-linux, and osx

import (
	"C"

	"github.com/exis-io/goRiffle"
)

// Required main method
func main() {}

//export Test
func Test() {
	goRiffle.Info("Server starting")
	goRiffle.SetLoggingDebug()

	a := goRiffle.NewDomain("xs.damouse.alpha")
	a.Join()

	e := a.Subscribe("sub", func() {
		goRiffle.Info("Pub received!")
	})

	if e != nil {
		goRiffle.Info("Unable to subscribe: ", e.Error())
	}

	e = a.Register("reg", func() {
		goRiffle.Info("Call received!")
	})

	if e != nil {
		goRiffle.Info("Unable to subscribe: ", e.Error())
	}

	// Run the client until Leave is called
	a.Run()
}

// // Required main method
// func main() {}

// //export Connector
// func Connector(url *C.char, domain *C.char) *C.char {
// 	ret := goRiffle.PConnector(C.GoString(url), C.GoString(domain))
// 	return C.CString(ret)
// }

// //export Subscribe
// func Subscribe(domain *C.char) []byte {
// 	return goRiffle.PSubscribe(C.GoString(domain))
// }

// //export Recieve
// func Recieve() []byte {
// 	return goRiffle.PRecieve()
// }

// //export Yield
// func Yield(args []byte) {
// 	goRiffle.PYield(args)
// }

// //export Register
// func Register(domain *C.char) []byte {
// 	return goRiffle.PRegister(C.GoString(domain))
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

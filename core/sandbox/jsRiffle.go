// package name: reef
package main

import (
	"github.com/exis-io/goriffle"
	"github.com/gopherjs/gopherjs/js"
)

// Required main method
func main() {
	js.Global.Set("pet", map[string]interface{}{
		"Test":      Test,
		"Connector": Connector,
		"Pure":      Pure,
	})
}

//export Connector
func Connector(url string, domain string) string {

	go func() {
		goriffle.PConnector(url, domain)
		// goriffle.PSubscribe("xs.damouse.hello")
		// fmt.Println("Done")
	}()
	return "Thanks"
}

func Pure(url string, domain string) {
	goriffle.GoJs(url, domain)
}

// //export Subscribe
// func Subscribe(domain *C.char) []byte {
// 	return riffle.PSubscribe(C.GoString(domain))
// }

// //export Recieve
// func Recieve() []byte {
// 	return riffle.PRecieve()
// }

// //export Yield
// func Yield(args []byte) {
// 	riffle.PYield(args)
// }

// //export Register
// func Register(domain *C.char) []byte {
// 	return riffle.PRegister(C.GoString(domain))
// }

//export Test
func Test() int {
	return 1
}

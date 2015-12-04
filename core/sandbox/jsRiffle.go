// package name: reef
package main

import (
	"fmt"
	"github.com/damouse/goriffle"
	"github.com/gopherjs/gopherjs/js"
)

/*
Works-- call with 
	riffle.go.Receiver("Publish")
	var go = require('./go.js');
	exports.go = global.core;
*/

// Required main method
func main() {
	js.Global.Set("core", map[string]interface{}{
		"Receiver":      Receiver,
		"Pure": 		Pure,
		"Native":		Connector,
	})
}

func Receiver(notification string) string {
	fmt.Println("Received a message")
	return "Thanks!"
}

// //export Connector
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

// // //export Subscribe
// // func Subscribe(domain *C.char) []byte {
// // 	return riffle.PSubscribe(C.GoString(domain))
// // }

// // //export Recieve
// // func Recieve() []byte {
// // 	return riffle.PRecieve()
// // }

// // //export Yield
// // func Yield(args []byte) {
// // 	riffle.PYield(args)
// // }

// // //export Register
// // func Register(domain *C.char) []byte {
// // 	return riffle.PRegister(C.GoString(domain))
// // }

// //export Test
// func Test() int {
// 	return 1
// }

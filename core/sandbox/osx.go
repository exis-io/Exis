// package name: reef
package main

import (
	"C"

	"github.com/exis-io/riffle"
)

// Required main method
func main() {}

//export Connector
func Connector(url *C.char, domain *C.char) *C.char {
	ret := riffle.PConnector(C.GoString(url), C.GoString(domain))
	return C.CString(ret)
}

//export Subscribe
func Subscribe(domain *C.char) []byte {
	return riffle.PSubscribe(C.GoString(domain))
}

//export Recieve
func Recieve() []byte {
	return riffle.PRecieve()
}

//export Yield
func Yield(args []byte) {
	riffle.PYield(args)
}

//export Register
func Register(domain *C.char) []byte {
	return riffle.PRegister(C.GoString(domain))
}

//export Test
func Test() int {
	return 1
}

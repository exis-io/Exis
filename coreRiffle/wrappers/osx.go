// package name: reef
package main

import (
	"C"
	"fmt"

	"github.com/damouse/coreRiffle"
)

// Required main method
func main() {}

//export Connector
func Connector(url *C.char, domain *C.char) *C.char {
	ret := coreRiffle.PConnector(C.GoString(url), C.GoString(domain))
	return C.CString(ret)
}

//export Subscribe
func Subscribe(domain *C.char) []byte {
	return coreRiffle.PSubscribe(C.GoString(domain))
}

//export Recieve
func Recieve() []byte {
	return coreRiffle.PRecieve()
}

//export Yield
func Yield(args []byte) {
	coreRiffle.PYield(args)
}

//export Register
func Register(domain *C.char) []byte {
	return coreRiffle.PRegister(C.GoString(domain))
}

//export Test
func Test() int {
	fmt.Println("Entering test")
	go spin()
	return 1
}

func spin() {
	fmt.Println("Starting")
	sum := 1
	for sum < 1000 {
		sum += sum
		fmt.Println(sum)
	}
}

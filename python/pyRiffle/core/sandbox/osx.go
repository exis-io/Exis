// package name: reef
package main

import (
	"C"
	"fmt"
	"github.com/damouse/goriffle"
)

// Required main method
func main() {}

//export Connector
func Connector(url *C.char, domain *C.char) *C.char {
	ret := goriffle.PConnector(C.GoString(url), C.GoString(domain))
	return C.CString(ret)
}

//export Subscribe
func Subscribe(domain *C.char) []byte {
	return goriffle.PSubscribe(C.GoString(domain))
}

//export Recieve
func Recieve() []byte {
	return goriffle.PRecieve()
}

//export Yield
func Yield(args []byte) {
	goriffle.PYield(args)
}

//export Register
func Register(domain *C.char) []byte {
	return goriffle.PRegister(C.GoString(domain))
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

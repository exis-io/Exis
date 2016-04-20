// package name: riffle
package main

import (
	"C"

	"github.com/exis-io/core"
)

// TODO: Passing in the connection, AppDomain and regular domain refactoring

// Required main method
func main() {}

// This is still here temporarily. Removed once client-generation is up and running
//export CBID
func CBID() uint64 {
	return core.NewID()
}

var sess = core.NewSession()

//export Send
func Send(i *C.char) {
	go sess.Send(C.GoString(i))
}

//export Receive
func Receive() *C.char {
	cb := <-sess.Receive()
	return C.CString(core.MantleMarshall(cb))
}

// package name: riffle
package main

import (
	"C"

	"github.com/exis-io/core"
    "github.com/exis-io/core/shared"
)

// TODO: Passing in the connection, AppDomain and regular domain refactoring

// Required main method
func main() {}

// This is still here temporarily. Removed once client-generation is up and running
// export CBID
func CBID() uint64 {
	return core.NewID()
}

// The results of this are not used, but we'd like to call it at the top level 
var n = core.SetConnectionFactory(shared.ConnectionFactory{})
var sess = core.NewSession()

//export Send
func Send(i *C.char) {
	go sess.Send(C.GoString(i))
}

//export SendSync
func SendSync(i *C.char) {
    sess.Send(C.GoString(i))
}

//export Receive
func Receive() *C.char {
	cb := <-sess.Receive()
	return C.CString(core.MantleMarshall(cb))
}

// package name: riffle
package main

import (
	"C"

	"github.com/exis-io/core"
    "github.com/exis-io/core/shared"
)

// The results of this are not used, but we'd like to call it at the top level 
var n = core.SetConnectionFactory(shared.ConnectionFactory{})
var sess = core.NewSession()

func main() {}

//export Send
func Send(i *C.char, sync bool) {
    if sync {
	   sess.Send(C.GoString(i))
    } else {
        go sess.Send(C.GoString(i))
    }
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
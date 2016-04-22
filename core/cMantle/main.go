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

var sess = NewSession

//export Send
func Send(i *C.char) {
	go sess.Send(C.CString(i))
}

//export Receive
func Receive() *C.char {
	cb := <-sess.Receive()
	return C.CString(core.MantleMarshall(cb))
}

// func Join(pdomain uint64, cb uint64, eb uint64) {
// 	d := get(pdomain)

// 	if c, err := shared.Open(core.Fabric); err != nil {
// 		d.GetApp().CallbackSend(eb, err.Error())
// 	} else {
// 		if err := d.Join(c); err != nil {
// 			d.GetApp().CallbackSend(eb, err.Error())
// 		} else {
// 			d.GetApp().CallbackSend(cb)
// 		}
// 	}
// }

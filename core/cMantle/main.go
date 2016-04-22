// package name: riffle
package main

import (
	"C"

	"github.com/exis-io/core"
)

// Required main method
func main() {}

//export CBID
func CBID() uint64 {
	return core.NewID()
}

//export Receive
func Receive(dptr uint64) *C.char {
	// Used to be a byte slice, but 1.6 cgo checks will not allow that
	d := get(dptr)
	return C.CString(core.MantleMarshall(d.GetApp().CallbackListen()))
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

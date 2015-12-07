// package name: riff
package main

import (
	"C"

	"github.com/exis-io/goRiffle"
)

// Required main method
func main() {}

//export Test
func Test() {
	goRiffle.Info("Server starting")
	goRiffle.SetLoggingDebug()

	a := goRiffle.NewDomain("xs.damouse.alpha")
	a.Join()

	e := a.Subscribe("sub", func() {
		goRiffle.Info("Pub received!")
	})

	if e != nil {
		goRiffle.Info("Unable to subscribe: ", e.Error())
	}

	e = a.Register("reg", func() {
		goRiffle.Info("Call received!")
	})

	if e != nil {
		goRiffle.Info("Unable to subscribe: ", e.Error())
	}

	// Run the client until Leave is called
	a.Run()
}

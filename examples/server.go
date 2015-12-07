package main

import "github.com/exis-io/goRiffle"

func main() {
	goRiffle.Info("Server starting")
	goRiffle.SetLogging(goRiffle.LOGDEBUG)

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

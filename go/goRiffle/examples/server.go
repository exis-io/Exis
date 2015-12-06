package main

import "github.com/exis-io/goRiffle"

func main() {
	goRiffle.Info("Server starting")

	a := goRiffle.NewDomain("xs.damouse.alpha")

	a.Join()

	e := a.Subscribe("reg", func() {
		goRiffle.Info("Call received!")
	})

	if e != nil {
		goRiffle.Info("Unable to subscribe: ", e.Error())
	}

	a.Run()
}

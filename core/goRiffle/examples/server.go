package main

import "github.com/exis-io/core/goRiffle"

func main() {
	// set flags for testing
	goRiffle.SetFabricDev()
	goRiffle.SetLogLevelDebug()

	app := goRiffle.NewDomain("xs.damouse")
	receiver := app.Subdomain("receiver")

	receiver.Join()

	if e := receiver.Subscribe("sub", func(name string) {
		goRiffle.Info("Pub received! Name: %s", name)
	}); e != nil {
		goRiffle.Info("Unable to subscribe: ", e.Error())
	} else {
		goRiffle.Info("Subscribed!")
	}

	// e = a.Register("reg", func() {
	// 	goRiffle.Info("Call received!")
	// })

	// if e != nil {
	// 	goRiffle.Info("Unable to subscribe: ", e.Error())
	// }

	// Handle until the connection closes
	receiver.Listen()
}

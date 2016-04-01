package main

import "github.com/exis-io/core/goRiffle"

func main() {
	// set flags for testing
	goRiffle.SetFabricDev()
	goRiffle.SetLogLevelInfo()

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

	if e := receiver.Register("reg", func(name string) string {
		goRiffle.Info("Call received! Name: %s", name)
		return "Hello from the server!"
	}); e != nil {
		goRiffle.Info("Unable to register: ", e.Error())
	} else {
		goRiffle.Info("Registered!")
	}

	// Handle until the connection closes
	receiver.Listen()
}

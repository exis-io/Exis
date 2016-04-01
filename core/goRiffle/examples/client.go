package main

import "github.com/exis-io/core/goRiffle"

func main() {
	// set flags for testing
	goRiffle.SetFabricDev()
	goRiffle.SetLogLevelDebug()

	// Create the domain objects
	app := goRiffle.NewDomain("xs.damouse")
	sender := app.Subdomain("sender")
	receiver := app.Subdomain("receiver")

	// Connect
	sender.Join()

	if e := receiver.Publish("sub", "Hello!"); e != nil {
		goRiffle.Info("Unable to publish: ", e.Error())
	} else {
		goRiffle.Info("Published!")
	}

	// Handle until the connection closes
	sender.Listen()
}

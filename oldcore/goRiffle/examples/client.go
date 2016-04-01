package main

import "github.com/exis-io/core/goRiffle"

func main() {
	// set flags for testing
	goRiffle.SetFabricDev()
	goRiffle.SetLogLevelInfo()

	// Create the domain objects
	app := goRiffle.NewDomain("xs.damouse")
	sender := app.Subdomain("sender")
	receiver := app.Subdomain("receiver")

	// Connect
	sender.Join()

	if e := receiver.Publish("sub", "Publish from Client"); e != nil {
		goRiffle.Info("Unable to publish: ", e.Error())
	} else {
		goRiffle.Info("Published!")
	}

	if ret, e := receiver.Call("reg", "Call from Client"); e != nil {
		goRiffle.Info("Unable to call: ", e.Error())
	} else {
		goRiffle.Info("Result of call: %v", ret)
	}

	// Handle until the connection closes
	sender.Listen()
}

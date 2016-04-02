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

	if e := receiver.Publish("sub", "Publish from Client"); e != nil {
		goRiffle.Info("Unable to publish: ", e.Error())
	} else {
		goRiffle.Info("Published!")
	}

	ret, _ := receiver.Call("reg", "Call from Client", goRiffle.Options{Progress: func(progress string) {
		goRiffle.Info("Progress: " + progress)
	}})

	goRiffle.Info("Final result of call: %s", ret)

	// Handle until the connection closes
	sender.Listen()
}

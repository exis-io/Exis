package main

import riffle "github.com/exis-io/core/riffle"

func main() {
	// set flags for testing
	riffle.SetFabricLocal()
	riffle.SetLogLevelDebug()

	// Create the domain objects
	app := riffle.NewDomain("xs.damouse")
	sender := app.Subdomain("sender")
	receiver := app.Subdomain("receiver")

	// Connect
	sender.Join()

	if e := receiver.Publish("sub", "Publish from Client"); e != nil {
		riffle.Info("Unable to publish: ", e.Error())
	} else {
		riffle.Info("Published!")
	}

	if ret, e := receiver.Call("reg", "Call from Client"); e != nil {
		riffle.Info("Unable to call: ", e.Error())
	} else {
		riffle.Info("Final result of call: %s", ret)
	}

	ret, _ := receiver.Call("progressive", "Call from Client", riffle.Options{Progress: func(progress string) {
		riffle.Info("Progress: " + progress)
	}})

	riffle.Info("Final result of call: %s", ret)

	// Handle until the connection closes
	sender.Listen()
}

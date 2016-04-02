package main

import "github.com/exis-io/core/goRiffle"

func reg(name string) (chan interface{}, chan interface{}) {
	goRiffle.Info("Starting progressive handler")

	progress, done := make(chan interface{}), make(chan interface{})

	go func() {
		for i := 1; i <= 10; i++ {
			progress <- "Some Progres"
		}

		done <- "Done!"
	}()

	return progress, done
}

func sub(name string) {
	goRiffle.Info("Pub received! Name: %s", name)
}

func main() {
	// set flags for testing
	goRiffle.SetFabricDev()
	goRiffle.SetLogLevelDebug()

	// Domain objects
	app := goRiffle.NewDomain("xs.damouse")
	receiver := app.Subdomain("receiver")

	// Connect
	receiver.Join()

	if e := receiver.Subscribe("sub", sub); e != nil {
		goRiffle.Info("Unable to subscribe: ", e.Error())
	} else {
		goRiffle.Info("Subscribed!")
	}

	if e := receiver.Register("reg", reg, goRiffle.Options{Progress: true}); e != nil {
		goRiffle.Info("Unable to register: ", e.Error())
	} else {
		goRiffle.Info("Registered!")
	}

	// Handle until the connection closes
	receiver.Listen()
}

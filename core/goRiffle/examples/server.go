package main

import "time"
import "fmt"
import "github.com/exis-io/core/goRiffle"

func reg(name string) (chan interface{}, chan interface{}) {
	goRiffle.Info("Starting progressive handler")

	progress, done := make(chan interface{}), make(chan interface{})

	go func() {
		for i := 1; i <= 5; i++ {
			progress <- fmt.Sprintf("Some Progress: %d", i)
			time.Sleep(1 * time.Second)
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
	goRiffle.SetFabricLocal()
	goRiffle.SetLogLevelDebug()

	// Domain objects
	app := goRiffle.NewDomain("xs.damouse")
	receiver := app.Subdomain("receiver")

	// Connect
	receiver.Join()

	/*
		if e := receiver.Subscribe("sub", sub); e != nil {
			goRiffle.Info("Unable to subscribe: ", e.Error())
		} else {
			goRiffle.Info("Subscribed!")
		}
	*/

	if e := receiver.Register("reg", reg, goRiffle.Options{Progress: true}); e != nil {
		goRiffle.Info("Unable to register: ", e.Error())
	} else {
		goRiffle.Info("Registered!")
	}

	// Handle until the connection closes
	receiver.Listen()
}

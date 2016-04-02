package main

import (
	"fmt"
	"time"

	riffle "github.com/exis-io/core/riffle"
)

func reg(name string) (chan interface{}, chan interface{}) {
	riffle.Info("Starting progressive handler")

	progress, done := make(chan interface{}), make(chan interface{})

	go func() {
		for i := 1; i <= 10; i++ {
			progress <- fmt.Sprintf("Some Progress: %d", i)
			time.Sleep(1 * 100 * time.Millisecond)
		}

		done <- "Done!"
	}()

	return progress, done
}

func regNoProgress(name string) string {
	riffle.Info("Receiver got message from " + name)
	return "This is patrick"
}

func sub(name string) {
	riffle.Info("Pub received! Name: %s", name)
}

func main() {
	// set flags for testing
	riffle.SetFabricLocal()
	riffle.SetLogLevelDebug()

	// Domain objects
	app := riffle.NewDomain("xs.damouse")
	receiver := app.Subdomain("receiver")

	// Connect
	receiver.Join()

	if e := receiver.Subscribe("sub", sub); e != nil {
		riffle.Info("Unable to subscribe: ", e.Error())
	} else {
		riffle.Info("Subscribed!")
	}

	if e := receiver.Register("reg", regNoProgress); e != nil {
		riffle.Info("Unable to register: ", e.Error())
	} else {
		riffle.Info("Registered!")
	}

	if e := receiver.Register("progressive", reg, riffle.Options{Progress: true}); e != nil {
		riffle.Info("Unable to register: ", e.Error())
	} else {
		riffle.Info("Registered!")
	}

	// Handle until the connection closes
	receiver.Listen()
}

package main

import "fmt"
import "github.com/exis-io/core/goRiffle"

func main() {
	// set flags for testing
	goRiffle.SetFabricLocal()
	goRiffle.SetLogLevelDebug()

	// Create the domain objects
	app := goRiffle.NewDomain("xs.damouse")
	sender := app.Subdomain("sender")
	receiver := app.Subdomain("receiver")

	// Connect
	sender.Join()

	receiver.Publish("sub1", "sub1 published")
	receiver.Publish("sub2", 64)
	receiver.Publish("sub3", "Sub3 not published")

	ret1, _ := receiver.Call("reg1", "reg1 called")
	fmt.Println("reg1 ", ret1)

	ret2, _ := receiver.Call("reg2", 64)
	fmt.Println("reg2 ", ret2)

	if ret3, err3 := receiver.Call("reg3", "Reg3 not called"); err3 != nil {
		fmt.Println("reg3 not called", err3)
	} else {
		fmt.Println("reg3 never called ", ret3)
	}

	// Handle until the connection closes
	sender.Listen()
}

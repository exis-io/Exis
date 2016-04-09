package main

import "github.com/exis-io/core/riffle"

func main() {
	// set flags for testing
	// riffle.SetFabricLocal()
	riffle.SetLogLevelDebug()

	// Create the domain objects
	app := riffle.NewDomain("xs.demo.damouse.dojo")
	// sender := app.Subdomain("sender")
	// receiver := app.Subdomain("receiver")

	// Auth 1 example
	// ok := app.RegisterDomain("a", "123465834543", "asdf@gmail.com", "asdf")
	//    riffle.Info("", ok)

	// if d, err := app.Login("a", "123465834543"); err != nil {
	// 	riffle.Warn("Unable to login: %s", err.Error())
	// } else {
	// 	riffle.Debug("Logged in with domain: %s", d)
	// }

	// Auth 0 example-- Still have to store the token!
	// if d, err := app.Login("a"); err != nil {
	// 	riffle.Warn("Unable to login: %s", err.Error())
	// } else {
	// 	riffle.Debug("Logged in with domain: %s", d)
	// }

	// Connect
	// sender.Join()

	// if e := receiver.Publish("sub", "Publish from Client"); e != nil {
	// 	riffle.Info("Unable to publish: ", e.Error())
	// } else {
	// 	riffle.Info("Published!")
	// }

	// if ret, e := receiver.Call("reg", "Call from Client"); e != nil {
	// 	riffle.Info("Unable to call: ", e.Error())
	// } else {
	// 	riffle.Info("Final result of call: %s", ret)
	// }

	// ret, _ := receiver.Call("progressive", "Call from Client", riffle.Options{Progress: func(progress string) {
	// 	riffle.Info("Progress: " + progress)
	// }})

	// riffle.Info("Final result of call: %s", ret)

	// // Handle until the connection closes
	// sender.Listen()
}

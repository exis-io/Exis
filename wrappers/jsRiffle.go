// package name: reef
package main

import (
	"fmt"

	"github.com/damouse/coreRiffle"
	"github.com/gopherjs/gopherjs/js"
)

var dommy *coreRiffle.Domain

// Required main method
func main() {
	js.Global.Set("core", map[string]interface{}{
		"Receiver": ExternalReceive,
		// "Domain":   coreRiffle.NewDomain,
		"Domain": Connector,
	})
}

func Connector(name string) *coreRiffle.Domain {
	dommy = coreRiffle.NewDomain(name)
	fmt.Println("Creating a new domain: ", dommy)
	return dommy
}

func ExternalReceive(msg string) {
	fmt.Println("Domain exists: ", dommy)

	if dommy == nil {
		fmt.Println("WARN: no domain exists to handle the message!")
		return
	}

	dommy.ReceiveExternal(msg)
}

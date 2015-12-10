package main

import (
	"fmt"

	"github.com/exis-io/core/goRiffle"
)

func main() {
	fmt.Println("Client starting")

	a := goRiffle.NewDomain("xs.damouse.beta")
	a.Join()

	// a.Call("xs.damouse/reg")
	a.Publish("xs.damouse/sub")

	a.Run()
}

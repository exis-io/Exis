package main

import (
	"fmt"

	"github.com/exis-io/core/goRiffle"
)

func main() {
	fmt.Println("Client starting")

	a := goRiffle.NewDomain("xs.damouse.beta")
	a.Join()

	a.Call("xs.damouse/reg", true, "Hello!")
	a.Publish("xs.damouse/sub", 3)

	a.Run()
}

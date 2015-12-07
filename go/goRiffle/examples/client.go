package main

import (
	"fmt"

	"github.com/exis-io/goRiffle"
)

func main() {
	fmt.Println("Client starting")

	a := goRiffle.NewDomain("xs.damouse.beta")
	a.Join()

	a.Call("xs.damouse.alpha/reg")
	a.Publish("xs.damouse.alpha/sub")

	a.Run()
}

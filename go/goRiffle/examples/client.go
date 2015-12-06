package main

import (
	"fmt"

	"github.com/exis-io/goRiffle"
)

func main() {
	fmt.Println("Client starting")

	a := goRiffle.NewDomain("xs.damouse.beta")

	a.Run()
}

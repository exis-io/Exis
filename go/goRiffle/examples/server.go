package main

import (
	"fmt"

	"github.com/exis-io/goRiffle"
)

func main() {
	fmt.Println("Server starting")

	a := goRiffle.NewDomain("xs.damouse.alpha")

	a.Join()

	e := a.Subscribe("reg", func() {
		fmt.Println("Call received!")
	})

	if e != nil {
		fmt.Println("Unable to subscribe: ", e.Error())
	}

	a.Run()
}

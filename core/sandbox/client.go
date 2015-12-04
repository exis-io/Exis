package main

import (
	"fmt"

	"github.com/exis-io/riffle"
)

func main() {
	session, err := riffle.Start("ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws", "xs.gotestclient")

	if err != nil {
		fmt.Println(err)
		return
	}

	// Values come out as an array, which I find meh. Should cuminize again
	ret, err := session.Call("xs.gotestserver/hello", 2, 3)
	fmt.Println("Call with result and error:", ret, err)

	session.Publish("xs.gotestserver/sub", 4, 5)
}

package main

import (
	"fmt"

	"github.com/exis-io/riffle"
)

var kill chan bool

func someCall(a int, b int) int {
	ret := a + b

	fmt.Println("Call received with args and return:", a, b, ret)
	return ret
}

func somePub(a int, b int) {
	fmt.Println("Pub received with args:", a, b)
	kill <- true
}

func main() {
	kill = make(chan bool)

	session, err := riffle.Start("ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws", "xs.gotestserver")

	if err != nil {
		fmt.Println(err)
		return
	}

	session.Register("xs.gotestserver/hello", someCall, nil)
	session.Subscribe("xs.gotestserver/sub", somePub)

	// End when the client is disconnected
	<-kill

	fmt.Println("Done!")
}

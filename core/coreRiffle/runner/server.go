package main

import (
	"fmt"

	"github.com/exis-io/riffle"
)

var session *riffle.Session

func someCall(a int, b int) int {
	ret := a + b

	fmt.Println("Call received with args and return:", a, b, ret)
	return ret
}

func somePub(a int, b int) {
	fmt.Println("Pub received with args:", a, b)
	session.Leave()
}

func main() {
	s, err := riffle.Start("ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws", "xs.gotestserver")
	session = s

	if err != nil {
		fmt.Println(err)
		return
	}

	session.Register("xs.gotestserver/hello", someCall, nil)
	session.Subscribe("xs.gotestserver/sub", somePub)

	// Block and recieve
	session.Receive()

	fmt.Println("Done!")
}

package main

import (
	"fmt"

	"github.com/exis-io/riffle"
)

func someFunc(a string, b int) int {
	fmt.Println(a, b)
	return 1
}

//////////////////////////////////////////
// Initial testing implementation
//////////////////////////////////////////

var kill chan bool

// func subArrived(args []interface{}, kwargs map[string]interface{}, details map[string]interface{}) (result *riffle.CallResult) {
// 	fmt.Println("\nCall received with args: %s", args)

// 	kill <- true

// 	result = &riffle.CallResult{
// 		Args: make([]interface{}, 0),
// 	}

// 	return
// }

func someCall(a int, b int) {
	fmt.Println("\nCall received with args: %s, %s", a, b)
	kill <- true
}

func testBasicRiffle() {
	kill = make(chan bool)

	session, err := riffle.Start("ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws", "xs.testerer")

	if err != nil {
		fmt.Println(err)
		return
	}

	// url := "ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws"
	// client, _ := riffle.NewWebsocketSession(riffle.JSON, url)

	// "Join a realm", which means try to authenticate using the hackied old system
	// session.JoinRealm("xs.testerer", nil)
	// go client.Receive()

	session.Register("xs.testerer/hello", someCall, nil)
	// client.Call("xs.testerer/hello", nil, nil)

	// End when the client is disconnected
	done := <-kill

	fmt.Printf("Done: %s", done)
}

func main() {
	// result, err := riffle.Cumin(someFunc, []interface{}{"hello", float64(2)})
	// fmt.Println(result)
	// fmt.Println(err)

	testBasicRiffle()
}

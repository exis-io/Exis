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

func subArrived(args []interface{}, kwargs map[string]interface{}, details map[string]interface{}) (result *riffle.CallResult) {
	fmt.Println("\nCall received with args: %s", args)

	kill <- true

	result = &riffle.CallResult{
		Args: make([]interface{}, 0),
	}

	return
}

func testBasicRiffle() {
	kill = make(chan bool)

	url := "ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws"
	client, _ := riffle.NewWebsocketClient(riffle.JSON, url)

	// "Join a realm", which means try to authenticate using the hackied old system
	client.JoinRealm("xs.testerer", nil)
	// go client.Receive()

	client.Register("xs.testerer/hello", subArrived, nil)
	// client.Call("xs.testerer/hello", nil, nil)

	// End when the client is disconnected
	done := <-kill

	fmt.Printf("Done: %s", done)
}

func main() {
	// result, err := riffle.Cumin(someFunc, []interface{}{"hello", 2})
	// fmt.Println(result)
	// fmt.Println(err)

	testBasicRiffle()
}

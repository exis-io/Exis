package main

import (
	"fmt"
	"reflect"

	"github.com/exis-io/riffle"
)

//////////////////////////////////////////
// Basics of Cumin
//////////////////////////////////////////
func testReflection(fn interface{}, args []interface{}) error {
	t := reflect.TypeOf(fn)

	// Check to make sure the pointer is actually a functions
	if t.Kind() != reflect.Func {
		return fmt.Errorf("Handler is not a function!")
	}

	// Iterate over the params listed in the method and try their casts
	for i := 0; i < t.NumIn(); i++ {
		fmt.Println(t.In(i))
	}

	return nil
}

func someFunc(a string, b int) {

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
	testReflection(someFunc, []interface{}{"hello", 2})
	// testBasicRiffle()
}

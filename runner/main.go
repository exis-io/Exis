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
	reciever := reflect.TypeOf(fn)
	// fnValue := reflect.ValueOf(fn)

	// Check to make sure the pointer is actually a functions
	if reciever.Kind() != reflect.Func {
		return fmt.Errorf("Handler is not a function!")
	}

	// Iterate over the params listed in the method and try their casts
	// values := make([]reflect.Value, len(args))
	for i := 0; i < reciever.NumIn(); i++ {
		param := reciever.In(i)
		arg := reflect.ValueOf(args[i])

		if param != arg.Type() {
			return fmt.Errorf("Cuminication failed. Expected type %s for argument at position %d in function %s. Recieved %s.", param, i, reciever, arg.Type())
		}

		fmt.Println(reciever.In(i))
		incomingArgument := reflect.ValueOf(args[i])
		fmt.Println(incomingArgument)
		// fmt.Printf("Expected: %s, Incoming: %s, Matches: %b", t.In(i), incomingArgument.Type(), t.In(i) == incomingArgument.Type())
		// values[x] = reflect.ValueOf(args[x])
	}

	return nil
}

// The working magic. Goooo magic.
func testReflectiveCast() {
	args := []interface{}{"hello", 2}
	values := make([]reflect.Value, len(args))

	for x := range args {
		values[x] = reflect.ValueOf(args[x])
	}

	fmt.Println(args)
	fmt.Println(values)

	fn := reflect.ValueOf(someFunc)
	fn.Call(values)
}

func someFunc(a string, b int) {
	fmt.Println(a, b)
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
	err := testReflection(someFunc, []interface{}{"hello", 2})
	// testBasicRiffle()
	// testReflectiveCast()

	fmt.Println(err)
}

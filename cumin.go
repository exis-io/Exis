package riffle

import (
	"fmt"
	"reflect"
)

func Cumin(fn interface{}, args []interface{}) ([]interface{}, error) {
	reciever := reflect.TypeOf(fn)
	var ret []interface{}

	// Check to make sure the pointer is actually a function
	if reciever.Kind() != reflect.Func {
		return ret, fmt.Errorf("Handler is not a function!")
	}

	// Iterate over the params listed in the method and try their casts
	values := make([]reflect.Value, len(args))
	for i := 0; i < reciever.NumIn(); i++ {
		param := reciever.In(i)
		arg := reflect.ValueOf(args[i])

		if param != arg.Type() {
			return ret, fmt.Errorf("Cuminication failed. Expected type %s for argument at position %d in function %s. Recieved %s.", param, i, reciever, arg.Type())
		}

		values[i] = arg
	}

	// Perform the call
	result := reflect.ValueOf(fn).Call(values)

	for x := range result {
		ret = append(ret, x)
	}

	// Return the result of the function

	// Catch any exceptions this produces and pass them to the function that sent them... or a handler block?
	return ret, nil
}

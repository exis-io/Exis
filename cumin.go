package goRiffle

import (
	"fmt"
	"reflect"
)

// Convert and apply args to arbitrary function fn
func cumin(fn interface{}, args []interface{}) ([]interface{}, error) {
	reciever := reflect.TypeOf(fn)
	var ret []interface{}

	// Check to make sure the pointer is actually a function
	if reciever.Kind() != reflect.Func {
		return ret, fmt.Errorf("Handler is not a function!")
	}

	if reciever.NumIn() != len(args) {
		return ret, fmt.Errorf("Cumin ERR: expected %s args for function %s, got %s", reciever.NumIn(), reciever, len(args))
	}

	// Iterate over the params listed in the method and try their casts
	values := make([]reflect.Value, len(args))
	for i := 0; i < reciever.NumIn(); i++ {
		param := reciever.In(i)
		arg := reflect.ValueOf(args[i])

		if param == arg.Type() {
			values[i] = arg
		} else if arg.Type().ConvertibleTo(param) {
			values[i] = arg.Convert(param)
		} else {
			return ret, fmt.Errorf("Cumin ERR: expected %s for arg[%d] in (%s), got %s.", param, i, reciever, arg.Type())
		}
	}

	// Perform the call
	result := reflect.ValueOf(fn).Call(values)

	for _, x := range result {
		ret = append(ret, x.Interface())
	}

	// Catch any exceptions this produces and pass them to the function that sent them, or some kind of handler

	return ret, nil
}

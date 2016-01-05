package core

import (
	"fmt"
	"reflect"
)

// Stores valid conversions FROM the json type TO the expected type. If the expected type is present in the row, 
// the conversion is valid
var conversionMatrix = map[reflect.Kind][]string{
    reflect.Bool: []string{"bool"},
    reflect.String: []string{"str"},
    reflect.Float64: []string{"int", "float"},
}

// Convert and apply args to arbitrary function fn
func Cumin(fn interface{}, args []interface{}) ([]interface{}, error) {
	reciever := reflect.TypeOf(fn)
	var ret []interface{}

	if reciever.Kind() != reflect.Func {
		return ret, fmt.Errorf("Handler is not a function!")
	}

	if reciever.NumIn() != len(args) {
		return ret, fmt.Errorf("Cumin: expected %s args for function %s, got %s", reciever.NumIn(), reciever, len(args))
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
			return ret, fmt.Errorf("Cumin: expected %s for arg[%d] in (%s), got %s.", param, i, reciever, arg.Type())
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

// Checks the types of the provided arguments and the receiver.
func softCumin(types []interface{}, args []interface{}) error {
    if len(types) != len(args) {
        return fmt.Errorf("Cumin: Invalid number of arguments, expected %d, receieved %s", len(types), len(args))
    }

	for i, x := range args {		
        v := reflect.ValueOf(x)
        expected := types[i]

        switch v.Kind() {
        case reflect.Bool: 
            if expected != "bool" {
                return fmt.Errorf("Cumin: got Bool for argument #%d, expected %s", i, expected)
            }

        case reflect.String: 
            if expected != "str" {
                return fmt.Errorf("Cumin: got String for argument #%d, expected %s", i, expected)
            }

        case reflect.Float64:
            if !(expected == "float" || expected == "int") {
                return fmt.Errorf("Cumin: got Number for argument #%d, expected %s", i, expected)
            }

        case reflect.Slice:
            // INCORRECT-- should iterate over values within the array, assuming a singly typed array
            
            if nestedSlice, ok := expected.([]interface{}); !ok {
                return fmt.Errorf("Cumin: got Array for argument #%d, expected %s", i, expected)
            } else if e := softCumin(nestedSlice, x.([]interface{})); e != nil {   
                return e
            }

        case reflect.Map:
            
        }

        if v.Kind() == reflect.Bool {

        }

        if v.Kind() == reflect.Slice {

        }

        if v.Kind() == reflect.Map {

        }
	}

	// int, string, bool, float, map, []string
	return nil
}

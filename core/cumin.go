package core

import (
	"fmt"
	"reflect"
)

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

// Checks the types of the provided positional arguments and the receiver.
func softCumin(types []interface{}, args []interface{}) error {
    // Until the node issue is resolved, softCumin isnt going to happen
    return nil
    
    //fmt.Printf("SoftCumin: %v against %v\n", types, args)

    if len(types) != len(args) {
        return fmt.Errorf("Cumin: Invalid number of arguments, expected %d, receieved %s", len(types), len(args))
    }

	for i, x := range args {		
        argument := reflect.ValueOf(x)
        expected := types[i]

        //fmt.Printf("Expected: %v Argument: %v\n", expected, x)
        //fmt.Printf("Type of expected: %v\n", reflect.ValueOf(expected))

        // If the expected type is a string, we're looking for a primitive
        if s, ok := expected.(string); ok {
            if e := primitiveCheck(s, argument.Kind()); e != nil {
                return e
            }
        } else if nestedSlice, ok := expected.([]string); ok {
            // An array of strings indicates an array of primitives. Each element of the array must be of the same type

            if len(nestedSlice) != 1 {
                return fmt.Errorf("Cumin: array expected at position #%d is not homogenous. %s", i, expected)
            }

            if argumentList, ok := x.([]interface{}); !ok {
                return fmt.Errorf("Cant read interface list %v at position %d", x, i)
            } else {
                for _, v := range argumentList {
                    if e := primitiveCheck(nestedSlice[0], reflect.ValueOf(v).Kind()); e != nil {
                        return e
                    }
                }
            }
        } else if _, ok := expected.([]map[string]interface{}); ok {
            // TODO: arrays of objects

            // fmt.Println("Array of objects, ", nestedSlice)
            // if len(nestedSlice) != 1 {
            //     return fmt.Errorf("Cumin: array expected at position #%d is not homogenous. %s", i, expected)
            // }

            // if argumentList, ok := x.([]map[string]interface{}); !ok {
            //     return fmt.Errorf("Cant read dictionary %v at position %d", x, i)
            // } else {
            //     for _, v := range argumentList {
            //         if e := mapCheck(nestedSlice[0], v); e != nil {
            //             return e
            //         }
            //     }
            // }
        } else if nestedMap, ok := expected.(map[string]interface{}); ok {  

            if argumentMap, ok := x.(map[string]interface{}); !ok {
                return fmt.Errorf("Cumin: expected dictionary at position %d, got %v", i, reflect.ValueOf(x))
            } else {
                if e := mapCheck(nestedMap, argumentMap); e != nil {
                    return e
                }
            }
        } else {
            return fmt.Errorf("Cumin: couldnt find primitive, list, or dictionary at #%d", i)
        }        
	}

	return nil
}

// Return an error if the argument is not of the expected type OR the expected type is not a primitive
func primitiveCheck(expected string, argument reflect.Kind) error {  
    if argument == reflect.Bool && expected == "bool" ||
        argument == reflect.String && expected == "str" ||
        argument == reflect.Float64 && (expected == "float" || expected == "int") ||
        argument == reflect.Int && (expected == "float" || expected == "int") {
        return nil
    }

    return fmt.Errorf("Cumin: got %s, expected %s", argument, expected) 
}

// Recursively check an object. Return nil if the object matches the expected types
func mapCheck(expected map[string]interface{}, argument map[string]interface{}) error {
    if len(expected) != len(argument) {
        return fmt.Errorf("Cumin: object invalid number of keys, expected %d, receieved %s", len(expected), len(argument))
    }

    // TODO: nested collections and objects
    for k, v := range argument {
        if e := primitiveCheck(expected[k].(string), reflect.ValueOf(v).Kind()); e != nil {
            return e
        }
    }

    return nil 
}







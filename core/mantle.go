package core

import (
	"encoding/json"
	"fmt"
	"reflect"
	"strings"
)

// Mentle version 2. Reflects the core, handles invocations, and manages memory based on the reflected
// api found in pkgreflect.go

// JSON rpc invocation structure. The json must be a list with at least 4 elements
// of the types below. All elements after the first 4 are parsed as arguments for the invocation
// The first three fields always behave the same, the last two have semantic meaning based
// on the Kind of the target
//
// Variable:
//      Address is unused. If exactly one argument is passed the mantle will try to assign it
//      to the variable. The current value of the variable is always returned.
//
//      Send(`["CuminLevel", 0, 1, 0, 2]`) // Changes the CuminLevel
//
// Function:
//      Address is unused for normal functions. All arguments are passed into that function.
//      Constructors are functions named New[TypeName] and must return a pointer to the constructed
//      type. In this case the address field is used to refer to that instance in the future.
//      Clients are expected to pick well-distrubted random values for address
//
//      mantle.Send(`["NewID", 10, 11, 0]`) // Normal Function
//      mantle.Send(`["NewApp", 10, 11, 12345]`) // Constructor for an App at address 12345
//
// Method:
//      Target refers to the name of the method, address is the same as previously generated.
//      All arguments are passed in as given.
//
//      mantle.Send(`["SetState", 10, 11, 12345, 1]`) // calls SetState on App created previously
//
// Control:
//      The current session is always at address 0. It implements control methods.
//
//      mantle.Send(`["Free", 10, 11, 0, 12345]`) // dealloc an instance

type rpc struct {
	target  string        // A type, function, variable, or constant
	cb      uint64        // The callback id to deliver the result on
	eb      uint64        // errback id to deliver failure on
	address uint64        // multiple-use field: "Pointer" when dealing with types, handler id for domain operations
	args    []interface{} // Arguments to pass to the target
}

// Sent up to the mantle and then the crust as callbacks are triggered
type Callback struct {
	Id   uint64
	Args []interface{}
}

type Session interface {
	Free(uint64)
	Send(string)
	Receive() chan Callback
}

type session struct {
	memory   map[uint64]interface{} // "heap" space for this session
	dispatch chan Callback
}

// Free the given object from memory. Does not check for presence
func (s *session) Free(id uint64) {
	fmt.Println("Freeing memory: ", id)
	delete(s.memory, id)
}

// Creates a new session. The session has itself as the second memory address
func NewSession() *session {
	s := &session{
		memory:   make(map[uint64]interface{}),
		dispatch: make(chan Callback, 0),
	}

	s.memory[1] = s
	return s
}

func (sess *session) Receive() chan Callback {
	return sess.dispatch
}

func (sess *session) Send(line string) {
	n, err := deserialize(line)

	if err != nil {
		fmt.Printf("Ignoring message %b. Error: %s\n", line, err.Error())
		return
	}

	result := Callback{Id: n.cb}

	if m, ok := Variables[n.target]; ok {
		result.Args = handleVariable(m, n.args)
	} else if m, ok := Consts[n.target]; ok {
		result.Args = []interface{}{m.Interface()}
	} else if m, ok := Functions[n.target]; ok {
		if ret, err := handleFunction(m, n.args); err != nil {
			result.Id = n.eb
			result.Args = []interface{}{err.Error()}
		} else {
			if handleConstructor(n.target, n.address, sess.memory, ret) {
				result.Args = []interface{}{n.address}
			} else {
				result.Args = ret
			}

			result.Id = n.cb
		}
	} else if m, ok := sess.memory[n.address]; ok {
		v := reflect.ValueOf(m).MethodByName(n.target)

		if ret, err := handleFunction(v, n.args); err != nil {
			fmt.Printf("Method not successful: %s\n", err.Error())
			result.Id = n.eb
			result.Args = []interface{}{err.Error()}
		} else {
			result.Id = n.cb
			result.Args = ret
		}
	} else {
		fmt.Printf("Unknown invocation: %v\n", n)
		return
	}

	sess.dispatch <- result
}

// Assign the given value to a variable and return its value. If we are passed "nil" as a
// new value this is just a read-- dont try and set the value. Obviously this means nil is
// not allowed as a variable value.
// TODO: handle bad type conversions
func handleVariable(v reflect.Value, n []interface{}) []interface{} {
	if len(n) == 1 {
		c := reflect.ValueOf(n[0]).Convert(v.Elem().Type())
		v.Elem().Set(c)
	}

	return []interface{}{v.Elem()}
}

func handleFunction(fn reflect.Value, args []interface{}) ([]interface{}, error) {
	return Cumin(fn.Interface(), args)
}

// Checks to see if a function invocation instantiated an object by checking the string of the target.
// By convention constructors must be named "New[TypeName]" and return pointers.
// If found and memory has been allocated for the given pointer, return true
func handleConstructor(target string, address uint64, memory map[uint64]interface{}, invocationResult []interface{}) bool {
	if len(invocationResult) != 1 {
		return false
	}

	if strings.Index(target, "New") != -1 {
		split := strings.Split(target, "New")

		if len(split) == 2 && split[0] == "" {
			memory[address] = invocationResult[0]
			return true
		}
	}

	return false
}

func deserialize(j string) (*rpc, error) {
	var d []interface{}
	if e := json.Unmarshal([]byte(j), &d); e != nil {
		return nil, fmt.Errorf("Unable to unmarshall data: %s\n", e)
	}

	n := &rpc{}

	if s, ok := d[0].(string); !ok {
		return nil, fmt.Errorf("Couldn't parse message-- incorrect type at position 0. Got %v", d[0])
	} else {
		n.target = s
	}

	if s, ok := d[1].(float64); !ok {
		return nil, fmt.Errorf("Couldn't parse message-- incorrect type at position 1. Got %v", d[1])
	} else {
		n.cb = uint64(s)
	}

	if s, ok := d[2].(float64); !ok {
		return nil, fmt.Errorf("Couldn't parse message-- incorrect type at position 2. Got %v", d[2])
	} else {
		n.eb = uint64(s)
	}

	if s, ok := d[3].(float64); !ok {
		return nil, fmt.Errorf("Couldn't parse message-- incorrect type at position 3. Got %v", d[2])
	} else {
		n.address = uint64(s)
	}

	n.args = d[4:]
	return n, nil
}

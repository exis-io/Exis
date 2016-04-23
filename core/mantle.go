package core

import (
	"encoding/json"
	"fmt"
	"reflect"
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
//      Send(`["CuminLevel", 0, 1, 0, 0, 2]`) // Changes the CuminLevel
//
// Function:
//      Address is unused for normal functions. All arguments are passed into that function.
//      Clients are expected to pick well-distrubted random values for address
//
//      mantle.Send(`["NewID", 10, 11, 0, 0]`) // Normal Function
//      mantle.Send(`["NewApp", 10, 11, 0, 12345]`) // Constructor for an App at address 12345
//
// Method:
//      Target refers to the name of the method, address is the same as previously generated.
//      All arguments are passed in as given.
//
//      mantle.Send(`["SetState", 10, 11, 0, 12345, 1]`) // calls SetState on App created previously
//
// Control:
//      The current session is always at address 1. It implements control methods.
//
//      mantle.Send(`["Free", 10, 11, 0, 1, 12345]`) // dealloc an instance

type rpc struct {
	target  string        // A type, function, variable, or constant
	cb      uint64        // The callback id to deliver the result on
	eb      uint64        // errback id to deliver failure on
	address uint64        // Multi use field- handler id and intended memory address for instantiations
    object  uint64        // If this is an method call, use this field as the memory address
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
		dispatch: make(chan Callback, 10),
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
		Warn("Ignoring message %b. Error: %s\n", line, err.Error())
		return
	}

    Debug("Mantle invoking %v", n)
	result := Callback{Id: n.cb}

	if m, ok := Variables[n.target]; ok {
		result.Args = handleVariable(m, n.args)
	} else if m, ok := Consts[n.target]; ok {
		result.Args = []interface{}{m.Interface()}
	} else if m, ok := Functions[n.target]; ok {
		if ret, err := sess.handleFunction(m, n); err != nil {
			result.Id = n.eb
			result.Args = []interface{}{err.Error()}
		} else {
			result.Args = ret
		}
	} else if m, ok := sess.memory[n.object]; ok {
		v := reflect.ValueOf(m).MethodByName(n.target)

		if ret, err := sess.handleFunction(v, n); err != nil {
			result.Id = n.eb
			result.Args = []interface{}{err.Error()}
		} else {
			result.Args = ret
		}
	} else {
		Warn("Unknown invocation: %v\n", n)

        for address, ptr := range sess.memory {
            Debug("Address: %d, pointer: %d", address, ptr)
        }

		return
	}

	sess.dispatch <- result
}

// Assign the given value to a variable and return its value. If we are passed "nil" as a
// new value this is just a read-- dont try and set the value. Obviously this means nil is
// not allowed as a variable value.
// TODO: handle bad type conversions
func handleVariable(v reflect.Value, n []interface{}) []interface{} {
    //Debug("Variable: setting %v to %v", v.Type(), n)

	if len(n) == 1 {
		c := reflect.ValueOf(n[0]).Convert(v.Elem().Type())
		v.Elem().Set(c)
	}

	return []interface{}{v.Elem()}
}

func (s *session) handleFunction(fn reflect.Value, n *rpc) ([]interface{}, error) {
	ret, err := Cumin(fn.Interface(), n.args)

    if err != nil {
        Warn("Function %v err: %s", fn, err.Error())
        return nil , err
    }

    // Check if any of the results returned are new instances. If so, allocate them memory 
    for _, r := range ret {
        i := reflect.TypeOf(r)
        for _, t := range Types {
            //fmt.Printf("Comparing %v to %v\n", i, t)
            
            if i.AssignableTo(t){
               s.memory[n.address] = r
               break
            }
        }
    }

    return ret, nil
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
		return nil, fmt.Errorf("Couldn't parse message-- incorrect type at position 3. Got %v", d[3])
	} else {
		n.address = uint64(s)
	}

    if s, ok := d[4].(float64); !ok {
        return nil, fmt.Errorf("Couldn't parse message-- incorrect type at position 3. Got %v", d[4])
    } else {
        n.object = uint64(s)
    }

	n.args = d[5:]
	return n, nil
}

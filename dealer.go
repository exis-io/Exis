package riffle

import (
	// "reflect"
	"strconv"
	"strings"
	"sync"
)

// A Dealer routes and manages RPC calls to callees.
type Dealer interface {
	// Register a procedure on an endpoint
	Register(Sender, *Register)
	// Unregister a procedure on an endpoint
	Unregister(Sender, *Unregister)
	// Call a procedure on an endpoint
	Call(Sender, *Call)
	// Return the result of a procedure call
	Yield(Sender, *Yield)
	// Handle an ERROR message from an invocation
	Error(Sender, *Error)
	dump() string
	hasRegistration(string) bool
	lostSession(*Session)
}

type RemoteProcedure struct {
	Endpoint    Sender
	Procedure   URI
	PassDetails bool
}

func NewRemoteProcedure(endpoint Sender, procedure URI, tags []string) RemoteProcedure {
	proc := RemoteProcedure{
		Endpoint:    endpoint,
		Procedure:   procedure,
		PassDetails: false,
	}

	for _, tag := range tags {
		switch {
		case tag == "details":
			proc.PassDetails = true
		}
	}

	return proc
}

type defaultDealer struct {
	// map registration IDs to procedures
	procedures map[ID]RemoteProcedure
	// map procedure URIs to registration IDs
	//TODO we may need to mutex around registrations if we had to for sessRegs below
	registrations map[URI]ID

	// Map InvocationID to RequestID so we can send the RequestID with the
	// result (lets caller know what request the result is for).
	requests map[ID]ID

	// Map InvocationID to Sender so we know where to send the response.
	callers map[ID]Sender

	// Keep track of registrations by session, so that we can clean up when the
	// session closes.  For each session, we have a map[URI]bool, which we are
	// using as a set of registrations (store true for register, delete for
	// unregister).
	sessionRegistrations map[Sender]map[URI]bool
	sessRegLock          sync.RWMutex
}

func NewDefaultDealer() Dealer {
	return &defaultDealer{
		procedures:           make(map[ID]RemoteProcedure),
		registrations:        make(map[URI]ID),
		requests:             make(map[ID]ID),
		callers:              make(map[ID]Sender),
		sessionRegistrations: make(map[Sender]map[URI]bool),
	}
}

func (d *defaultDealer) Register(callee Sender, msg *Register) {
	// Endpoint may contain a # sign to pass comma-separated tags.
	// Example: pd.agent/function#details
	parts := strings.SplitN(string(msg.Procedure), "#", 2)
	endpoint := URI(parts[0])

	var tags []string
	if len(parts) > 1 {
		tags = strings.Split(parts[1], ",")
	}

	if id, ok := d.registrations[endpoint]; ok {
		//log.Println("error: procedure already exists:", msg.Procedure, id)
		out.Error("error: procedure already exists:", endpoint, id)
		callee.Send(&Error{
			Type:    msg.MessageType(),
			Request: msg.Request,
			Details: make(map[string]interface{}),
			Error:   ErrProcedureAlreadyExists,
		})
		return
	}

	reg := NewID()
	d.procedures[reg] = NewRemoteProcedure(callee, endpoint, tags)
	d.registrations[endpoint] = reg

	d.sessRegLock.Lock()
	if d.sessionRegistrations[callee] == nil {
		d.sessionRegistrations[callee] = make(map[URI]bool)
	}
	d.sessionRegistrations[callee][endpoint] = true
	d.sessRegLock.Unlock()

	//log.Printf("registered procedure %v [%v]", reg, msg.Procedure)
	callee.Send(&Registered{
		Request:      msg.Request,
		Registration: reg,
	})
}

func (d *defaultDealer) Unregister(callee Sender, msg *Unregister) {
	if procedure, ok := d.procedures[msg.Registration]; !ok {
		// the registration doesn't exist
		//log.Println("error: no such registration:", msg.Registration)
		callee.Send(&Error{
			Type:    msg.MessageType(),
			Request: msg.Request,
			Details: make(map[string]interface{}),
			Error:   ErrNoSuchRegistration,
		})
	} else {
		d.sessRegLock.Lock()
		delete(d.sessionRegistrations[callee], procedure.Procedure)
		d.sessRegLock.Unlock()
		delete(d.registrations, procedure.Procedure)
		delete(d.procedures, msg.Registration)
		//log.Printf("unregistered procedure %v [%v]", procedure.Procedure, msg.Registration)
		callee.Send(&Unregistered{
			Request: msg.Request,
		})
	}
}

func (d *defaultDealer) Call(caller Sender, msg *Call) {
	if reg, ok := d.registrations[msg.Procedure]; !ok {
		caller.Send(&Error{
			Type:    msg.MessageType(),
			Request: msg.Request,
			Details: make(map[string]interface{}),
			Error:   ErrNoSuchProcedure,
		})
	} else {
		if rproc, ok := d.procedures[reg]; !ok {
			// found a registration id, but doesn't match any remote procedure
			caller.Send(&Error{
				Type:    msg.MessageType(),
				Request: msg.Request,
				Details: make(map[string]interface{}),
				// TODO: what should this error be?
				Error: URI("wamp.error.internal_error"),
			})
		} else {
			// everything checks out, make the invocation request
			args := msg.Arguments
			kwargs := msg.ArgumentsKw

			// Remote procedures with the PassDetails flag set will receive a
			// special first argument set by the node.
			if rproc.PassDetails {
				details := make(map[string]interface{})

				// Make sure the argument list exists first.
				if args == nil {
					args = make([]interface{}, 0)
				}

				// Does the caller want to be disclosed?
				// We default to true unless he explicitly says otherwise.
				disclose_caller, ok := msg.Options["disclose_me"].(bool)
				if !ok {
					disclose_caller = true
				}

				if disclose_caller {
					sess := caller.(*Session)
					if sess != nil {
						details["caller"] = sess.pdid
					}
				}

				// Insert as the first positional argument.
				args = append(args, nil)
				copy(args[1:], args[:])
				args[0] = details
			}

			invocationID := NewID()
			d.requests[invocationID] = msg.Request
			d.callers[invocationID] = caller

			rproc.Endpoint.Send(&Invocation{
				Request:      invocationID,
				Registration: reg,
				Details:      map[string]interface{}{},
				Arguments:    args,
				ArgumentsKw:  kwargs,
			})
		}
	}
}

func (d *defaultDealer) Yield(callee Sender, msg *Yield) {
	caller, ok := d.callers[msg.Request]
	if !ok {
		// WAMP spec doesn't allow sending an error in response to a YIELD message
		//log.Println("received YIELD message with invalid invocation request ID:", msg.Request)
		return
	}

	delete(d.callers, msg.Request)

	requestId, ok := d.requests[msg.Request]
	if !ok {
		return
	}

	delete(d.requests, msg.Request)

	// return the result to the caller
	caller.Send(&Result{
		Request:     requestId,
		Details:     map[string]interface{}{},
		Arguments:   msg.Arguments,
		ArgumentsKw: msg.ArgumentsKw,
	})
}

func (d *defaultDealer) Error(peer Sender, msg *Error) {
	caller, ok := d.callers[msg.Request]
	if !ok {
		//log.Println("received ERROR (INVOCATION) message with invalid invocation request ID:", msg.Request)
		return
	}

	delete(d.callers, msg.Request)

	requestId, ok := d.requests[msg.Request]
	if !ok {
		//log.Printf("received ERROR (INVOCATION) message, but unable to match it (%v) to a CALL ID", msg.Request)
		return
	}

	delete(d.requests, msg.Request)

	// return an error to the caller
	caller.Send(&Error{
		Type:        CALL,
		Request:     requestId,
		Details:     make(map[string]interface{}),
		Arguments:   msg.Arguments,
		ArgumentsKw: msg.ArgumentsKw,
		Error:       msg.Error,
	})
}

// Remove all the registrations for a session that has disconected
func (d *defaultDealer) lostSession(sess *Session) {
	// TODO: Do something about outstanding requests

	// Make a copy of the uri's
	regs := make(map[URI]bool)
	d.sessRegLock.RLock()
	for uri, v := range d.sessionRegistrations[sess] {
		regs[uri] = v
	}
	d.sessRegLock.RUnlock()

	for uri, _ := range regs {
		out.Debug("Unregister: %s", string(uri))
		delete(d.procedures, d.registrations[uri])
		delete(d.registrations, uri)
	}

	d.sessRegLock.Lock()
	delete(d.sessionRegistrations, sess)
	d.sessRegLock.Unlock()
}

func (d *defaultDealer) dump() string {
	ret := "  functions:"

	for k, v := range d.procedures {
		ret += "\n\t" + strconv.FormatUint(uint64(k), 16) + ": " + string(v.Procedure)
	}

	ret += "\n  registrations:"

	for k, v := range d.registrations {
		ret += "\n\t" + string(k) + ": " + strconv.FormatUint(uint64(v), 16)
	}

	ret += "\n  callers:"

	for k, _ := range d.callers {
		ret += "\n\t" + strconv.FormatUint(uint64(k), 16) + ": (sender)"
	}

	ret += "\n  requests:"

	for k, v := range d.requests {
		ret += "\n\t" + strconv.FormatUint(uint64(k), 16) + ": " + strconv.FormatUint(uint64(v), 16)
	}

	return ret
}

// Testing. Not sure if this works 100 or not
func (d *defaultDealer) hasRegistration(s string) bool {
	_, exists := d.registrations[URI(s)]
	return exists
}

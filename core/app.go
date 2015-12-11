package core

import (
	"encoding/json"
	"fmt"
	"log"
	"reflect"
	"time"
)

type App interface {
	NewDomain(string) Domain

	ReceiveBytes([]byte)
	ReceiveString(string)
	ReceiveMessage(message)

	Yield(uint, []interface{})
	Close(string)

	CallbackListen() Callback
	CallbackSend(uint, ...interface{})
}

type app struct {
	domains []*domain
	Connection
	serializer
	in        chan message
	out       chan []byte
	up        chan Callback
	listeners map[uint]chan message
}

// Sent up to the mantle and then the crust as callbacks are triggered
type Callback struct {
	Id   uint
	Args []interface{}
}

func NewApp() App {
	return &app{
		domains:    make([]*domain, 0),
		serializer: new(jSONSerializer),
		in:         make(chan message, 10),
		out:        make(chan []byte, 10),
		up:         make(chan Callback, 10),
		listeners:  make(map[uint]chan message),
	}
}

func (a *app) CallbackListen() Callback {
	m := <-a.up
	return m
}

func (a *app) CallbackSend(id uint, args ...interface{}) {
	// Debug("Sending: %s", args)
	a.up <- Callback{id, args}
}

// Create a new domain. If no superdomain is provided, creates an app as well
// If the app exists, has a connection, and is connected then immediately call onJoin on that domain
func (a *app) NewDomain(name string) Domain {
	Debug("Creating domain %s", name)

	d := &domain{
		app:           a,
		name:          name,
		joined:        false,
		subscriptions: make(map[uint]*boundEndpoint),
		registrations: make(map[uint]*boundEndpoint),
	}

	// TODO: trigger onJoin if the superdomain has joined

	a.domains = append(a.domains, d)
	return d
}

func (c app) Send(m message) error {
	Debug("Sending: %s: %s", m.messageType(), m)

	if b, err := c.serializer.serialize(m); err != nil {
		return err
	} else {
		c.out <- b
		return nil
	}
}

func (c app) SendNow(m message) error {
	Debug("Sending: %s: %s", m.messageType(), m)
	if b, err := c.serializer.serialize(m); err != nil {
		return err
	} else {
		c.Connection.Send(b)
		return nil
	}
}

func (c app) Close(reason string) {
	Info("Asked to close! Reason: ", reason)

	close(c.in)
	close(c.out)
	close(c.up)

	// Theres some missing logic here when it comes to closing the external connection,
	// especially when either end could call and trigger a close
}

func (a app) Yield(request uint, args []interface{}) {
	m := &yield{
		Request:   request,
		Options:   make(map[string]interface{}),
		Arguments: args,
	}

	// if err != nil {
	//     m = &errorMessage{
	//         Type:      iNVOCATION,
	//         Request:   request,
	//         Details:   make(map[string]interface{}),
	//         Arguments: args,
	//         Error:     "Not Implemented",
	//     }
	// }

	if err := a.Send(m); err != nil {
		Warn("Could not send yield")
	} else {
		Info("Yield: %s", m)
	}
}

func (c app) receiveLoop() {
	for {
		if msg, open := <-c.in; !open {
			Warn("Receive loop close")
			break
		} else {
			Debug("Received message: ", msg)
			c.handle(msg)
		}
	}
}

// This guy doesn't need to be here
func (c app) sendLoop() {
	for {
		if b, open := <-c.out; !open {
			Info("Send loop closed")
			break
		} else {
			c.Connection.Send(b)
		}
	}
}

// Handles an incoming message appropriately
func (c app) handle(msg message) {
	switch msg := msg.(type) {

	case *event:
		for _, x := range c.domains {
			if binding, ok := x.subscriptions[msg.Subscription]; ok {
				go x.handlePublish(msg, binding)
				return
			}
		}

		Warn("No handler registered for subscription:", msg.Subscription)

	case *invocation:
		for _, x := range c.domains {
			if binding, ok := x.registrations[msg.Registration]; ok {
				go x.handleInvocation(msg, binding)
				return
			}
		}

		Warn("No handler registered for registration:", msg.Registration)
		s := fmt.Sprintf("no handler for registration: %v", msg.Registration)
		m := &errorMessage{Type: iNVOCATION, Request: msg.Request, Details: make(map[string]interface{}), Error: s}

		if err := c.Send(m); err != nil {
			Warn("error sending message:", err)
		}

	case *goodbye:
		c.Close("Fabric said goodbye. Closing connection")

	default:
		id, ok := requestID(msg)

		// Catch control messages here and replace getMessageTimeout

		if ok {
			if l, found := c.listeners[id]; found {
				l <- msg
			} else {
				log.Println("no listener for message", msg)
				Info("Listeners: ", c.listeners)
				// panic("Unhandled message!")
			}
		} else {
			panic("Bad handler picking up requestID!")
		}
	}
}

// All incoming messages end up here one way or another
func (c app) ReceiveMessage(msg message) {
	c.in <- msg
}

// Do we really want to throw errors back into the connection here?
func (c app) ReceiveString(msg string) {
	c.ReceiveBytes([]byte(msg))
}

// Theres a method on the serializer that does this exact thing. Is this specific to JS?
func (c app) ReceiveBytes(byt []byte) {
	var dat []interface{}

	if err := json.Unmarshal(byt, &dat); err != nil {
		Info("Unable to unmarshal json! Message: ", dat)
	} else {
		if m, err := c.serializer.deserializeString(dat); err == nil {
			c.in <- m
		} else {
			Info("Unable to unmarshal json string! Message: ", m)
		}
	}
}

// Send a message and blocks until the expected type of message is returned
// String check on the type... pretty bad. Come back to this and figure out how to reflect the interface
func (c *app) requestListenType(outgoing message, expecting string) (message, error) {
	if err := c.Send(outgoing); err != nil {
		return nil, err
	}

	wait := make(chan message, 1)
	id, _ := requestID(outgoing)

	c.listeners[id] = wait
	defer delete(c.listeners, id)

	select {
	case msg := <-wait:
		// Debug("incoming: %s, expecting: %s", reflect.TypeOf(msg), expecting)

		if e, ok := msg.(*errorMessage); ok {
			return nil, fmt.Errorf(e.Error)
		} else if reflect.TypeOf(msg).String() != expecting {
			return nil, fmt.Errorf(formatUnexpectedMessage(msg, expecting))
		} else {
			return msg, nil
		}
	case <-time.After(MessageTimeout):
		return nil, fmt.Errorf("timeout while waiting for message")
	}
}

// Blocks on a message from the connection. Don't use this while the run loop is active
func (c app) getMessageTimeout() (message, error) {
	select {
	case msg, open := <-c.in:
		if !open {
			return nil, fmt.Errorf("receive channel closed")
		}

		return msg, nil
	case <-time.After(MessageTimeout):
		return nil, fmt.Errorf("timeout waiting for message")
	}
}

package core

import (
	"encoding/json"
	"fmt"
	"reflect"
	"time"
)

type App interface {
	ReceiveBytes([]byte)
	ReceiveString(string)
	ReceiveMessage(message)

	Yield(uint64, []interface{})

	Close(string)
	ConnectionClosed(string)

	CallbackListen() Callback
	CallbackSend(uint64, ...interface{})
}

type app struct {
	domains []*domain
	Connection
	serializer
	agent     string
	in        chan message
	up        chan Callback
	listeners map[uint64]chan message
}

// Sent up to the mantle and then the crust as callbacks are triggered
type Callback struct {
	Id   uint64
	Args []interface{}
}

func (a *app) CallbackListen() Callback {
	m := <-a.up
	return m
}

func (a *app) CallbackSend(id uint64, args ...interface{}) {
	a.up <- Callback{id, args}
}

func (c app) Send(m message) error {
	Debug("Sending %s: %v", m.messageType(), m)

	// There's going to have to be a better way of handling these messages
	if b, err := c.serializer.serialize(m); err != nil {
		return err
	} else {
		c.Connection.Send(b)
		return nil
	}
}

func (c app) Close(reason string) {
	Info("Closing internally: ", reason)

	if err := c.Send(&goodbye{Details: map[string]interface{}{}, Reason: ErrCloseRealm}); err != nil {
		Warn("Error sending goodbye: %v", err)
	}

	close(c.in)
	close(c.up)

	// Theres some missing logic here when it comes to closing the external connection,
	// especially when either end could call and trigger a close
	c.Connection.Close(reason)
}

func (c app) ConnectionClosed(reason string) {
	Info("Connection was closed: ", reason)

	close(c.in)
	close(c.up)
}

func (a app) Yield(request uint64, args []interface{}) {
	m := &yield{
		Request:   request,
		Options:   make(map[string]interface{}),
		Arguments: args,
	}

	if err := a.Send(m); err != nil {
		Warn("Could not send yield")
	}
}

// Not fully implemented
func (a app) YieldError(request uint64, args []interface{}) {
	m := &errorMessage{
		Type:      iNVOCATION,
		Request:   request,
		Details:   make(map[string]interface{}),
		Arguments: args,
		Error:     "Not Implemented",
	}

	if err := a.Send(m); err != nil {
		Warn("Could not send yield error")
	}
}

func (c app) receiveLoop() {
	for {
		if msg, open := <-c.in; !open {
			Debug("Receive loop close")
			break
		} else {
			Debug("Received %s: %v", msg.messageType(), msg)
			c.handle(msg)
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

		// We can't be delivered to a sub we don't have... right?
		Warn("No handler registered for subscription:", msg.Subscription)

	case *invocation:
		for _, x := range c.domains {
			if binding, ok := x.registrations[msg.Registration]; ok {
				go x.handleInvocation(msg, binding)
				return
			}
		}

		s := fmt.Sprintf("no handler for registration: %v", msg.Registration)
		Warn(s)

		m := &errorMessage{Type: iNVOCATION, Request: msg.Request, Details: make(map[string]interface{}), Error: s}

		if err := c.Send(m); err != nil {
			Warn("error sending message:", err)
		}

	case *goodbye:
		c.Close("Fabric said goodbye. Closing connection")
		panic("Not implemented!")

	default:
		id, ok := requestID(msg)

		// Catch control messages here and replace getMessageTimeout

		if ok {
			if l, found := c.listeners[id]; found {
				l <- msg
			} else {
				Warn("no listener for message %v", msg)
				panic("Unhandled message!")
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

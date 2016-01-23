package core

import (
	"encoding/json"
	"fmt"
	"os"
	"reflect"
	"sync"
	"time"
)

type App interface {
	ReceiveBytes([]byte)
	ReceiveMessage(message)

	Yield(uint64, []interface{})
	YieldError(uint64, string, []interface{})

	Close(string)
	ConnectionClosed(string)

	CallbackListen() Callback
	CallbackSend(uint64, ...interface{})

	// Temporary location, will move to security
	SetToken(string)
}

type app struct {
	domains []*domain
	Connection
	serializer

	in   chan message
	up   chan Callback
	open bool

	listeners     map[uint64]chan message
	listenersLock sync.Mutex

	// authentication options
	agent  string
	authid string
	token  string
	key    string
}

// Sent up to the mantle and then the crust as callbacks are triggered
type Callback struct {
	Id   uint64
	Args []interface{}
}

func NewApp() *app {
	a := &app{
		domains:    make([]*domain, 0),
		serializer: new(jSONSerializer),
		open:       false,
		in:         make(chan message, 10),
		up:         make(chan Callback, 10),
		listeners:  make(map[uint64]chan message),
		token:      "",
	}

	a.authid = os.Getenv("EXIS_AUTHID")
	a.token = os.Getenv("EXIS_TOKEN")
	a.key = os.Getenv("EXIS_KEY")

	return a
}

func (a *app) CallbackListen() Callback {
	m := <-a.up
	return m
}

func (a *app) CallbackSend(id uint64, args ...interface{}) {
	a.up <- Callback{id, args}
}

func (c *app) Send(m message) error {
	Debug("Sending %s: %v", m.messageType(), m)

	// There's going to have to be a better way of handling these errors
	if b, err := c.serializer.serialize(m); err != nil {
		return err
	} else {
		c.Connection.Send(b)
		return nil
	}
}

func (c *app) Close(reason string) {
	if !c.open {
		// TODO: JS calls close one to many times. Please stop it.
		Warn("JS specific bandaid triggered!")
		return
	} else {
		Info("Closing internally: ", reason)
	}

	if err := c.Send(&goodbye{Details: map[string]interface{}{}, Reason: ErrCloseSession}); err != nil {
		Warn("Error sending goodbye: %v", err)
	}

	c.open = false
	close(c.in)
	close(c.up)

	// Theres some missing logic here when it comes to closing the external connection,
	// especially when either end could call and trigger a close
	c.Connection.Close(reason)
}

func (c *app) ConnectionClosed(reason string) {
	Info("Connection was closed: ", reason)

	c.open = false
	close(c.in)
	close(c.up)

	Info("Closing channels in ConnectionCLOSED, %v", c.open)
}

// Represents the result of an invokation in the crust
func (a *app) Yield(request uint64, args []interface{}) {
	m := &yield{
		Request:   request,
		Options:   make(map[string]interface{}),
		Arguments: args,
	}

	if err := a.Send(m); err != nil {
		Warn("Could not send yield")
	}
}

// Represents an error that ocurred during an invocation in the crust
func (a *app) YieldError(request uint64, etype string, args []interface{}) {
	m := &errorMessage{
		Type:      iNVOCATION,
		Request:   request,
		Details:   make(map[string]interface{}),
		Arguments: args,
		Error:     etype,
	}

	if err := a.Send(m); err != nil {
		Warn("Could not send yield error")
	}
}

func (c *app) receiveLoop() {
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
func (c *app) handle(msg message) {
	switch msg := msg.(type) {

	case *challenge:
		go c.handleChallenge(msg)
		return

	case *event:
		for _, x := range c.domains {
			x.subLock.RLock()
			if binding, ok := x.subscriptions[msg.Subscription]; ok {
				x.subLock.RUnlock()
				go x.handlePublish(msg, binding)
				return
			} else {
				x.subLock.RUnlock()
			}
		}

		// We can't be delivered to a sub we don't have... right?
		Warn("No handler registered for subscription:", msg.Subscription)

	case *invocation:
		for _, x := range c.domains {
			x.regLock.RLock()
			if binding, ok := x.registrations[msg.Registration]; ok {
				x.regLock.RUnlock()
				go x.handleInvocation(msg, binding)
				return
			} else {
				x.regLock.RUnlock()
			}
		}

		s := fmt.Sprintf("no handler for registration: %v", msg.Registration)
		Warn(s)

		m := &errorMessage{
			Type:    iNVOCATION,
			Request: msg.Request,
			Details: make(map[string]interface{}),
			Error:   ErrNoSuchRegistration,
		}

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
			c.listenersLock.Lock()
			if l, found := c.listeners[id]; found {
				l <- msg
				c.listenersLock.Unlock()
			} else {
				c.listenersLock.Unlock()
				Error("No listener for message %v", msg)
			}
		} else {
			panic("Bad handler picking up requestID!")
		}
	}
}

// All incoming messages end up here one way or another
func (c *app) ReceiveMessage(msg message) {
	if c.open {
		c.in <- msg
	}
}

// Theres a method on the serializer that does this exact thing. Is this specific to JS?
func (c *app) ReceiveBytes(byt []byte) {
	var dat []interface{}

	if err := json.Unmarshal(byt, &dat); err != nil {
		Info("Unable to unmarshal json! Message: %v", string(byt))
	} else {
		if m, err := c.serializer.deserializeString(dat); err == nil {
			c.ReceiveMessage(m)
		} else {
			Info("Unable to unmarshal json string! Message: %v", m)
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

	c.listenersLock.Lock()
	c.listeners[id] = wait
	c.listenersLock.Unlock()

	defer func() {
		c.listenersLock.Lock()
		delete(c.listeners, id)
		c.listenersLock.Unlock()
	}()

	select {
	case msg := <-wait:
		if e, ok := msg.(*errorMessage); ok {
			return nil, fmt.Errorf(e.Error)
		} else if reflect.TypeOf(msg).String() != expecting {
			return nil, fmt.Errorf(formatUnexpectedMessage(msg, expecting))
		} else {
			return msg, nil
		}
	case <-time.After(MessageTimeout):
		return nil, fmt.Errorf("Timeout while waiting for message")
	}
}

// Blocks on a message from the connection. Don't use this while the run loop is active,
// since it will compete for messages with the run loop. Bad things will happen.
// This is largely an orphan, and should be replaced.
func (c *app) getMessageTimeout() (message, error) {
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

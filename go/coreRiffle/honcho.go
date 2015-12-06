package coreRiffle

import (
	"encoding/json"
	"fmt"
	"log"
	"time"
)

type Persistence interface {
	Load(string, []byte)
	Save(string, []byte)
}

// Interface to external connection implementations
type Connection interface {
	// Send a message
	Send([]byte)

	// Closes the peer connection and any channel returned from Receive().
	// Calls with a reason for the close
	Close(string) error
}

// Manages a set of domains, receives messages from the wrapper's connections
type Honcho interface {
	NewDomain(string, Delegate) Domain

	ReceiveBytes([]byte)
	ReceiveString(string)
	ReceiveMessage(message)

	Close(string)
}

type honcho struct {
	domains []*domain
	Connection
	serializer
	in        chan message
	out       chan []byte
	listeners map[uint]chan message
}

// Initialize the core
func NewHoncho() Honcho {
	return honcho{
		domains:    make([]*domain, 0),
		serializer: new(jSONSerializer),
		in:         make(chan message, 10),
		out:        make(chan []byte, 10),
		listeners:  make(map[uint]chan message),
	}
}

func (c honcho) NewDomain(name string, del Delegate) Domain {
	d := domain{
		honcho:        &c,
		Delegate:      del,
		name:          name,
		joined:        false,
		subscriptions: make(map[uint]*boundEndpoint),
		registrations: make(map[uint]*boundEndpoint),
	}

	c.domains = append(c.domains, &d)
	return d
}

// One of our local domains left the fabric by choice
func (c *honcho) domainLeft(d *domain) error {
	if dems, ok := removeDomain(c.domains, d); !ok {
		return fmt.Errorf("WARN: couldn't find %s to remove!", d)
	} else {
		c.domains = dems
	}

	if err := c.Send(&goodbye{
		Details: map[string]interface{}{},
		Reason:  ErrCloseRealm,
	}); err != nil {
		return fmt.Errorf("Error leaving fabric: %v", err)
	}

	// if no domains remain, terminate the connection
	if len(c.domains) == 0 {
		c.Close("Closing: no domains connected")
	}

	return nil
}

func (c *honcho) domainJoined(d *domain) {
	// Join domains that are not joined already
	for _, x := range c.domains {
		if !x.joined {
			x.joined = true
			x.Delegate.OnJoin(d.name)
		}
	}
}

func (c honcho) Send(m message) error {
	Debug("Sending: %s: %s", m.messageType(), m)
	if b, err := c.serializer.serialize(m); err != nil {
		return err
	} else {
		c.out <- b
		return nil
	}
}

func (c honcho) SendNow(m message) error {
	Debug("Sending: %s: %s", m.messageType(), m)
	if b, err := c.serializer.serialize(m); err != nil {
		return err
	} else {
		c.Connection.Send(b)
		return nil
	}
}

func (c honcho) Close(reason string) {
	Info("Asked to close! Reason: ", reason)

	close(c.in)
	close(c.out)

	// Theres some missing logic here when it comes to closing the external connection,
	// especially when either end could call and trigger a close
}

func (c honcho) receiveLoop() {
	// Debug("Receive loop opened")

	for {
		if msg, open := <-c.in; !open {
			Warn("Receive loop close")
			break
		} else {
			Info("Received message", msg)
			c.handle(msg)
		}
	}
}

func (c honcho) sendLoop() {
	// Debug("Send loop opened")

	for {
		if b, open := <-c.out; !open {
			Info("Send loop closed")
			break
		} else {
			c.Connection.Send(b)
		}
	}
}

func (c honcho) handle(msg message) {
	switch msg := msg.(type) {

	case *event:
		for _, x := range c.domains {
			if _, ok := x.subscriptions[msg.Subscription]; ok {
				go x.handlePublish(msg)
			}
		}

	case *invocation:
		for _, x := range c.domains {
			if _, ok := x.registrations[msg.Registration]; ok {
				go x.handleInvocation(msg)
			}
		}

	case *goodbye:
		c.Close("Fabric said goodbye. Closing connection")

	default:
		if l, ok := c.listeners[requestID(msg)]; ok {
			l <- msg
		} else {
			log.Println("no listener for message", msg)
			Info("Listeners: ", c.listeners)
			panic("Unhandled message!")
		}
	}
}

// All incoming messages end up here one way or another
func (c honcho) ReceiveMessage(msg message) {
	// c.Handle(msg)
	c.in <- msg
}

// Do we really want to throw errors back into the connection here?
func (c honcho) ReceiveString(msg string) {
	c.ReceiveBytes([]byte(msg))
}

// Theres a method on the serializer that does this exact thing. Is this specific to JS?
func (c honcho) ReceiveBytes(byt []byte) {
	Debug("Received bytes")

	var dat []interface{}

	if err := json.Unmarshal(byt, &dat); err != nil {
		Info("Unable to unmarshal json! Message: ", dat)
		return
	}

	if m, err := c.serializer.deserializeString(dat); err == nil {
		// c.Handle(m)
		c.in <- m
	} else {
		Info("Unable to unmarshal json string! Message: ", m)
	}
}

// Send a message and wait for the response
func (c *honcho) requestListen(outgoing message) (message, error) {
	if err := c.Send(outgoing); err != nil {
		return nil, err
	}

	wait := make(chan message, 1)
	c.listeners[requestID(outgoing)] = wait
	// delete the listener on receive

	select {
	case msg := <-wait:
		if e, ok := msg.(*errorMessage); ok {
			return nil, fmt.Errorf(e.Error)
		}

		return msg, nil
	case <-time.After(MessageTimeout):
		return nil, fmt.Errorf("timeout while waiting for message")
	}
}

// Blocks on a message from the connection. Don't use this while the run loop is
// active
func (c honcho) getMessageTimeout() (message, error) {
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

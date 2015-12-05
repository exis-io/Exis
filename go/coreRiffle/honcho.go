package coreRiffle

import (
	"encoding/json"
	"fmt"
	"log"
	"time"
)

type Connection interface {
	// Send a message
	Send(message) error

	// Closes the peer connection and any channel returned from Receive().
	// Calls with a reason for the close
	Close(string)

	// Receive returns a channel of messages coming from the peer.
	// NOTE: I think this should be reactive
	Receive() <-chan message

	// Wait for a message for a timeout amount of time
	BlockMessage() (message, error)
}

type Persistence interface {
	Load(string []byte)
	Save(string, []byte)
}

// Keeps track of all the domains and handles message passing between them
// You do not get another connection for every domain, but you can
// with another honcho

type Honcho interface {
	NewDomain(string, Delegate) Domain

	HandleBytes([]byte)
	HandleString(string)
	HandleMessage(message)
}

type honcho struct {
	Connection
	domains []*domain
	serializer
	listeners map[uint]chan message
}

// Initialize the core
func Initialize() Honcho {
	return honcho{
		serializer: new(jSONSerializer),
		domains:    make([]*domain, 0),
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

	if err := c.Connection.Send(&goodbye{
		Details: map[string]interface{}{},
		Reason:  ErrCloseRealm,
	}); err != nil {
		return fmt.Errorf("Error leaving fabric: %v", err)
	}

	// if no domains remain, terminate the connection
	if len(c.domains) == 0 {
		c.Connection.Close("Closing: no domains connected")
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

// All incoming messages end up here one way or another
func (c honcho) HandleMessage(msg message) {
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
		c.Connection.Close("Fabric said goodbye. Closing connection")
	default:
		if l, ok := c.listeners[requestID(msg)]; ok {
			l <- msg
		} else {
			log.Println("no listener for message", msg)
			panic("Unhandled message!")
		}
	}
}

// Do we really want to throw errors back into the connection here?
func (c honcho) HandleString(msg string) {
	c.HandleBytes([]byte(msg))
}

// Theres a method on the serializer that does this exact thing. Is this specific to JS?
func (c honcho) HandleBytes(byt []byte) {
	var dat []interface{}

	if err := json.Unmarshal(byt, &dat); err != nil {
		fmt.Println("Unable to unmarshal json! Message: ", dat)
		return
	}

	if m, err := c.serializer.deserializeString(dat); err == nil {
		c.HandleMessage(m)
	} else {
		fmt.Println("Unable to unmarshal json string! Message: ", m)
	}
}

// Send a message and wait for the response
func (c *honcho) requestListen(outgoing message) (message, error) {
	if err := c.Send(outgoing); err != nil {
		return nil, err
	}

	wait := make(chan message, 1)

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

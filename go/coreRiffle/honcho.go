package coreRiffle

import (
	"encoding/json"
	"fmt"
	"log"
	"time"
)

// Keeps track of all the domains and handles message passing between them

type Honcho interface {
	HandleBytes([]byte) error
	HandleString(string) error
	HandleMessage(message) error
}

type honco struct {
	domains []*Domain
	serializer
	listeners map[uint]chan message
}

// Initialize the core
func Initialize(d Delegate) *Honcho {
	return &honco{
		serializer: new(jSONSerializer),
		domains:    make([]*Domain),
		listeners:  make(map[uint]chan message),
	}
}

func (c *honco) Newdomain(name string) *Domain {
	d := &domain{
		Delegate:      d,
		name:          name,
		subscriptions: make(map[uint]*boundEndpoint),
		registrations: make(map[uint]*boundEndpoint),
		joined:        false,
	}

	c.domains = append(c.domains, d)
	return d
}

func (c *honco) HandleMessage(msg message) {
	switch msg := msg.(type) {

	case *event:
		for d := range c.domains {
			if found, ok := d.subscriptions[msg.Subscription]; ok {
				d.handlePublish(msg)
			}
		}

	case *invocation:
		for d := range c.domains {
			if found, ok := d.registrations[msg.Registration]; ok {
				go d.handleInvocation(msg)
				return
			}
		}

		if err := c.Send(&errorMessage{
			Type:    iNVOCATION,
			Request: msg.Request,
			Details: make(map[string]interface{}),
			Error:   fmt.Sprintf("no handler for registration: %v", msg.Registration),
		}); err != nil {
			log.Println("error sending message:", err)
		}

	case *registered:
		c.notifyListener(msg, msg.Request)
	case *subscribed:
		c.notifyListener(msg, msg.Request)
	case *unsubscribed:
		c.notifyListener(msg, msg.Request)
	case *unregistered:
		c.notifyListener(msg, msg.Request)
	case *result:
		c.notifyListener(msg, msg.Request)
	case *errorMessage:
		c.notifyListener(msg, msg.Request)

	case *goodbye:
		break

	default:
		log.Println("unhandled message:", msg.messageType(), msg)
		panic("Unhandled message!")
	}
}

func (c *honco) HandleString(msg string) error {
	return c.HandleBytes([]byte(msg))
}

func (c *honco) HandleBytes(byt []byte) error {
	var dat []interface{}

	if err := json.Unmarshal(byt, &dat); err != nil {
		return err
	}

	if m, err := c.serializer.deserializeString(dat); err == nil {
		c.Handle(m)
	} else {
		return err
	}
}

func (c *honco) registerListener(id uint) {
	wait := make(chan message, 1)
	c.listeners[id] = wait
}

func (c *honco) waitOnListener(id uint) (message, error) {
	if wait, ok := c.listeners[id]; !ok {
		return nil, fmt.Errorf("unknown listener uint: %v", id)
	} else {
		select {
		case msg := <-wait:
			return msg, nil
		case <-time.After(timeout):
			return nil, fmt.Errorf("timeout while waiting for message")
		}
	}
}

func (c *honco) notifyListener(msg message, requestId uint) {
	if l, ok := c.listeners[requestId]; ok {
		l <- msg
	} else {
		log.Println("no listener for message", msg.messageType(), requestId)
	}
}

package coreRiffle

import (
	"encoding/json"
	"fmt"
	"log"
	"time"
)

type domaine interface {
	Subscribe(string, []interface{}) (uint, error)
	Register(string, []interface{}) (uint, error)

	Publish(string, []interface{}) error
	Call(string, []interface{}, []interface{}) (uint, error)

	Unsubscribe(string) error
	Unregister(string) error

	Join(Connection)
	Leave()
}

type domain struct {
	Connection
	Delegate
	name       string
	listeners  map[uint]chan message
	events     map[uint]*boundEndpoint
	procedures map[uint]*boundEndpoint
}

type boundEndpoint struct {
	endpoint string
	handler  interface{}
}

func Newdomain(name string) *domain {
	// The commented out line is js specific

	return &domain{
		name:       name,
		listeners:  make(map[uint]chan message),
		events:     make(map[uint]*boundEndpoint),
		procedures: make(map[uint]*boundEndpoint),
	}
}

func (s *domain) Subdomain(name string) *domain {
	return &domain{
		name:       s.name + "." + name,
		listeners:  make(map[uint]chan message),
		events:     make(map[uint]*boundEndpoint),
		procedures: make(map[uint]*boundEndpoint),
	}
}

// Accepts a connection that has just been opened
func (c *domain) Join(conn Connection) error {
	c.Connection = conn

	if err := c.Send(&hello{Realm: c.name, Details: map[string]interface{}{}}); err != nil {
		conn.Close()
		return err
	}

	if msg, err := conn.BlockMessage(); err != nil {
		conn.Close()
		return err
	} else if _, ok := msg.(*welcome); !ok {
		conn.Send(abortUnexpectedMsg)
		conn.Close()
		return fmt.Errorf(formatUnexpectedMessage(msg, wELCOME))
	} else {
		return nil
	}
}

func (c *domain) Leave() error {
	if err := c.Send(goodbyeSession); err != nil {
		return fmt.Errorf("error leaving realm: %v", err)
	}

	if err := c.Connection.Close(); err != nil {
		return fmt.Errorf("error closing client connection: %v", err)
	}

	return nil
}

/////////////////////////////////////////////
// Handler methods
/////////////////////////////////////////////

// Receive handles messages from the server until this client disconnects.
// This function blocks and is most commonly run in a goroutine.
func (c *domain) Receive() {
	for msg := range c.Connection.Receive() {
		c.Handle(msg)
	}
}

// Does not spin, does not block-- is called with updates
func (c *domain) ReceiveExternal(msg string) {
	byt := []byte(msg)
	var dat []interface{}

	if err := json.Unmarshal(byt, &dat); err != nil {
		fmt.Println(err)
		return
	}

	seer := new(jSONSerializer)
	fmt.Println("Received a message: ", msg)

	m, err := seer.deserializeString(dat)
	if err != nil {
		log.Println("error deserializing message:", err)
		log.Println(msg)
	} else {
		fmt.Println("Message received!")
		c.Handle(m)
	}
}

func (c *domain) Handle(msg message) {
	switch msg := msg.(type) {

	case *event:
		if event, ok := c.events[msg.Subscription]; ok {
			go cumin(event.handler, msg.Arguments)
		} else {
			log.Println("no handler registered for subscription:", msg.Subscription)
		}

	case *invocation:
		c.handleInvocation(msg)

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
		// panic("Unhandled message!")
	}
}

/////////////////////////////////////////////
// Message Patterns
/////////////////////////////////////////////

// Subscribe registers the EventHandler to be called for every message in the provided topic.
func (c *domain) Subscribe(topic string, fn interface{}) error {
	id := newID()
	c.registerListener(id)

	sub := &subscribe{
		Request: id,
		Options: make(map[string]interface{}),
		Name:    topic,
	}

	if err := c.Send(sub); err != nil {
		return err
	}

	// wait to receive sUBSCRIBED message
	msg, err := c.waitOnListener(id)
	if err != nil {
		return err
	} else if e, ok := msg.(*errorMessage); ok {
		return fmt.Errorf("error subscribing to topic '%v': %v", topic, e.Error)
	} else if subscribed, ok := msg.(*subscribed); !ok {
		return fmt.Errorf(formatUnexpectedMessage(msg, sUBSCRIBED))
	} else {
		// register the event handler with this subscription
		c.events[subscribed.Subscription] = &boundEndpoint{topic, fn}
	}
	return nil
}

// Unsubscribe removes the registered EventHandler from the topic.
func (c *domain) Unsubscribe(topic string) error {
	subscriptionID, _, ok := bindingForEndpoint(c.events, topic)

	if !ok {
		return fmt.Errorf("domain %s is not registered with this client.", topic)
	}

	id := newID()
	c.registerListener(id)

	sub := &unsubscribe{
		Request:      id,
		Subscription: subscriptionID,
	}

	if err := c.Send(sub); err != nil {
		return err
	}

	// wait to receive uNSUBSCRIBED message
	msg, err := c.waitOnListener(id)
	if err != nil {
		return err
	} else if e, ok := msg.(*errorMessage); ok {
		return fmt.Errorf("error unsubscribing to topic '%v': %v", topic, e.Error)
	} else if _, ok := msg.(*unsubscribed); !ok {
		return fmt.Errorf(formatUnexpectedMessage(msg, uNSUBSCRIBED))
	}

	delete(c.events, subscriptionID)
	return nil
}

func (c *domain) Register(procedure string, fn interface{}, options map[string]interface{}) error {
	id := newID()
	c.registerListener(id)

	register := &register{
		Request: id,
		Options: options,
		Name:    procedure,
	}

	if err := c.Send(register); err != nil {
		return err
	}

	// wait to receive rEGISTERED message
	msg, err := c.waitOnListener(id)
	if err != nil {
		return err
	} else if e, ok := msg.(*errorMessage); ok {
		return fmt.Errorf("error registering procedure '%v': %v", procedure, e.Error)
	} else if registered, ok := msg.(*registered); !ok {
		return fmt.Errorf(formatUnexpectedMessage(msg, rEGISTERED))
	} else {
		// register the event handler with this registration
		c.procedures[registered.Registration] = &boundEndpoint{procedure, fn}
	}
	return nil
}

// Unregister removes a procedure with the Node
func (c *domain) Unregister(procedure string) error {
	procedureID, _, ok := bindingForEndpoint(c.procedures, procedure)

	if !ok {
		return fmt.Errorf("domain %s is not registered with this client.", procedure)
	}

	id := newID()
	c.registerListener(id)

	unregister := &unregister{
		Request:      id,
		Registration: procedureID,
	}

	if err := c.Send(unregister); err != nil {
		return err
	}

	// wait to receive uNREGISTERED message
	msg, err := c.waitOnListener(id)
	if err != nil {
		return err
	} else if e, ok := msg.(*errorMessage); ok {
		return fmt.Errorf("error unregister to procedure '%v': %v", procedure, e.Error)
	} else if _, ok := msg.(*unregistered); !ok {
		return fmt.Errorf(formatUnexpectedMessage(msg, uNREGISTERED))
	}

	// register the event handler with this unregistration
	delete(c.procedures, procedureID)
	return nil
}

// Publish publishes an eVENT to all subscribed peers.
func (c *domain) Publish(endpoint string, args ...interface{}) error {
	return c.Send(&publish{
		Request:   newID(),
		Options:   make(map[string]interface{}),
		Name:      endpoint,
		Arguments: args,
	})
}

// Call calls a procedure given a URI.
func (c *domain) Call(procedure string, args ...interface{}) ([]interface{}, error) {
	id := newID()
	c.registerListener(id)

	call := &call{
		Request:   id,
		Name:      procedure,
		Options:   make(map[string]interface{}),
		Arguments: args,
	}

	if err := c.Send(call); err != nil {
		return nil, err
	}

	// wait to receive rESULT message
	msg, err := c.waitOnListener(id)
	if err != nil {
		return nil, err
	} else if e, ok := msg.(*errorMessage); ok {
		return nil, fmt.Errorf("error calling procedure '%v': %v", procedure, e.Error)
	} else if result, ok := msg.(*result); !ok {
		return nil, fmt.Errorf(formatUnexpectedMessage(msg, rESULT))
	} else {
		return result.Arguments, nil
	}
}

func (c *domain) handleInvocation(msg *invocation) {
	if proc, ok := c.procedures[msg.Registration]; ok {
		go func() {
			result, err := cumin(proc.handler, msg.Arguments)
			var tosend message

			tosend = &yield{
				Request:   msg.Request,
				Options:   make(map[string]interface{}),
				Arguments: result,
			}

			if err != nil {
				tosend = &errorMessage{
					Type:      iNVOCATION,
					Request:   msg.Request,
					Details:   make(map[string]interface{}),
					Arguments: result,
					Error:     err.Error(),
				}
			}

			if err := c.Send(tosend); err != nil {
				log.Println("error sending message:", err)
			}
		}()
	} else {
		//log.Println("no handler registered for registration:", msg.Registration)

		if err := c.Send(&errorMessage{
			Type:    iNVOCATION,
			Request: msg.Request,
			Details: make(map[string]interface{}),
			Error:   fmt.Sprintf("no handler for registration: %v", msg.Registration),
		}); err != nil {
			log.Println("error sending message:", err)
		}
	}
}

func bindingForEndpoint(bindings map[uint]*boundEndpoint, endpoint string) (uint, *boundEndpoint, bool) {
	for id, p := range bindings {
		if p.endpoint == endpoint {
			return id, p, true
		}
	}

	return 0, nil, false
}

func (c *domain) registerListener(id uint) {
	//log.Println("register listener:", id)
	wait := make(chan message, 1)
	c.listeners[id] = wait
}

func (c *domain) waitOnListener(id uint) (message, error) {
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

func (c *domain) notifyListener(msg message, requestId uint) {
	// pass in the request uint so we don't have to do any type assertion
	if l, ok := c.listeners[requestId]; ok {
		l <- msg
	} else {
		log.Println("no listener for message", msg.messageType(), requestId)
	}
}

// Convenience function to get a single message from a peer

package coreRiffle

import (
	"fmt"
	"log"
)

// The reeceiving end
type Delegate interface {

	// Called by core when something needs doing
	Invoke(string, uint, []interface{}, map[string]interface{})

	OnJoin(string)
	OnLeave(string)
}

type Domain interface {
	Subscribe(string, []interface{}) (uint, error)
	Register(string, []interface{}, map[string]interface{}) (uint, error)

	Publish(string, ...interface{}) error
	Call(string, ...interface{}) ([]interface{}, error)

	Unsubscribe(string) error
	Unregister(string) error

	Join(Connection) error
	Leave() error
}

type domain struct {
	Delegate
	honcho
	name          string
	joined        bool
	subscriptions map[uint]*boundEndpoint
	registrations map[uint]*boundEndpoint
}

type boundEndpoint struct {
	endpoint      string
	expectedTypes []interface{}
}

func (s *domain) Subdomain(name string) *domain {
	return &domain{
		Delegate:      s.Delegate,
		honcho:        s.honcho,
		name:          s.name + "." + name,
		joined:        s.joined,
		subscriptions: make(map[uint]*boundEndpoint),
		registrations: make(map[uint]*boundEndpoint),
	}
}

// Accepts a connection that has just been opened. This method should only
// be called once, to initialize the fabric
func (c *domain) Join(conn Connection) error {
	if c.joined {
		return fmt.Errorf("Domain %s is already joined", c.name)
	}

	// Should we hard close on conn.Close()? The Head Honcho may be interested in that...
	if err := conn.Send(&hello{Realm: c.name, Details: map[string]interface{}{}}); err != nil {
		conn.Close("ERR: could not send a hello message")
		return err
	}

	if msg, err := conn.BlockMessage(); err != nil {
		conn.Close(err.Error())
		return err
	} else if _, ok := msg.(*welcome); !ok {
		conn.Send(&abort{
			Details: map[string]interface{}{},
			Reason:  "Error- unexpected_message_type",
		})
		conn.Close("Error- unexpected_message_type")
		return fmt.Errorf(formatUnexpectedMessage(msg, wELCOME))
	} else {

		c.honcho.Connection = conn
		c.honcho.domainJoined(*c)
		return nil
	}
}

func (c *domain) Leave() error {
	return c.honcho.domainLeft(c)
}

/////////////////////////////////////////////
// Message Patterns
/////////////////////////////////////////////

// Subscribe registers the EventHandler to be called for every message in the provided endpoint.
func (c *domain) Subscribe(endpoint string, types []interface{}) (uint, error) {
	id := c.honcho.registerListener()

	sub := &subscribe{
		Request: id,
		Options: make(map[string]interface{}),
		Name:    endpoint,
	}

	if err := c.honcho.Send(sub); err != nil {
		return 0, err
	}

	if msg, err := c.honcho.waitOnListener(id, "subscribing to endpoint"); err != nil {
		return 0, err
	} else if subbed, ok := msg.(*subscribed); !ok {
		return 0, fmt.Errorf(formatUnexpectedMessage(msg, sUBSCRIBED))
	} else {
		c.subscriptions[subbed.Subscription] = &boundEndpoint{endpoint, types}
		return subbed.Subscription, nil
	}
}

// Unsubscribe removes the registered EventHandler from the endpoint.
func (c *domain) Unsubscribe(endpoint string) error {
	subscriptionID, _, ok := bindingForEndpoint(c.subscriptions, endpoint)

	if !ok {
		return fmt.Errorf("domain %s is not registered with this client.", endpoint)
	}

	id := c.honcho.registerListener()

	sub := &unsubscribe{
		Request:      id,
		Subscription: subscriptionID,
	}

	if err := c.honcho.Send(sub); err != nil {
		return err
	}

	if msg, err := c.honcho.waitOnListener(id, "unsubscribing from endpint "+endpoint); err != nil {
		return err
	} else if _, ok := msg.(*unsubscribed); !ok {
		return fmt.Errorf(formatUnexpectedMessage(msg, uNSUBSCRIBED))
	}

	delete(c.subscriptions, subscriptionID)
	return nil
}

func (c *domain) Register(procedure string, types []interface{}, options map[string]interface{}) (uint, error) {
	id := c.honcho.registerListener()

	register := &register{
		Request: id,
		Options: options,
		Name:    procedure,
	}

	if err := c.honcho.Send(register); err != nil {
		return 0, err
	}

	// TODO: emit an event for defereds!

	msg, err := c.honcho.waitOnListener(id, "registering endpoint")
	if err != nil {
		return 0, err
	} else if reg, ok := msg.(*registered); !ok {
		return 0, fmt.Errorf(formatUnexpectedMessage(msg, rEGISTERED))
	} else {
		c.registrations[reg.Registration] = &boundEndpoint{procedure, types}
		return reg.Registration, nil
	}
}

// Unregister removes a procedure with the Node
func (c *domain) Unregister(procedure string) error {
	procedureID, _, ok := bindingForEndpoint(c.registrations, procedure)

	if !ok {
		return fmt.Errorf("domain %s is not registered with this client.", procedure)
	}

	id := c.honcho.registerListener()

	unregister := &unregister{
		Request:      id,
		Registration: procedureID,
	}

	if err := c.honcho.Send(unregister); err != nil {
		return err
	}

	// wait to receive uNREGISTERED message
	msg, err := c.honcho.waitOnListener(id, "unregistering")
	if err != nil {
		return err
	} else if e, ok := msg.(*errorMessage); ok {
		return fmt.Errorf("error unregister to procedure '%v': %v", procedure, e.Error)
	} else if _, ok := msg.(*unregistered); !ok {
		return fmt.Errorf(formatUnexpectedMessage(msg, uNREGISTERED))
	}

	// register the event handler with this unregistration
	delete(c.registrations, procedureID)
	return nil
}

// Publish publishes an eVENT to all subscribed peers.
func (c *domain) Publish(endpoint string, args ...interface{}) error {
	return c.honcho.Send(&publish{
		Request:   newID(),
		Options:   make(map[string]interface{}),
		Name:      endpoint,
		Arguments: args,
	})
}

// Call calls a procedure given a URI.
func (c *domain) Call(procedure string, args ...interface{}) ([]interface{}, error) {
	id := c.honcho.registerListener()

	call := &call{
		Request:   id,
		Name:      procedure,
		Options:   make(map[string]interface{}),
		Arguments: args,
	}

	if err := c.honcho.Send(call); err != nil {
		return nil, err
	}

	if msg, err := c.honcho.waitOnListener(id, "calling procedure"); err != nil {
		return nil, err
	} else if result, ok := msg.(*result); !ok {
		return nil, fmt.Errorf(formatUnexpectedMessage(msg, rESULT))
	} else {
		return result.Arguments, nil
	}
}

func (c *domain) handleInvocation(msg *invocation) {
	if binding, ok := c.registrations[msg.Registration]; ok {
		go func() {
			// Check the return types
			if err := softCumin(binding.expectedTypes, msg.Arguments); err == nil {
				c.Delegate.Invoke(c.name, msg.Registration, msg.Arguments, msg.ArgumentsKw)
			} else {
				tosend := &errorMessage{
					Type:      iNVOCATION,
					Request:   msg.Request,
					Details:   make(map[string]interface{}),
					Arguments: msg.Arguments,
					Error:     err.Error(),
				}

				if err := c.honcho.Send(tosend); err != nil {
					log.Println("error sending message:", err)
				}
			}

			// Careful-- we can't yield in some languages
			// var tosend message

			// tosend = &yield{
			// 	Request:   msg.Request,
			// 	Options:   make(map[string]interface{}),
			// 	Arguments: result,
			// }

			// if err != nil {
			// 	tosend = &errorMessage{
			// 		Type:      iNVOCATION,
			// 		Request:   msg.Request,
			// 		Details:   make(map[string]interface{}),
			// 		Arguments: result,
			// 		Error:     err.Error(),
			// 	}
			// }

			// if err := c.honcho.Send(tosend); err != nil {
			// 	log.Println("error sending message:", err)
			// }
		}()
	} else {
		if err := c.honcho.Send(&errorMessage{
			Type:    iNVOCATION,
			Request: msg.Request,
			Details: make(map[string]interface{}),
			Error:   fmt.Sprintf("no handler for registration: %v", msg.Registration),
		}); err != nil {
			log.Println("error sending message:", err)
		}
	}
}

func (c *domain) handlePublish(msg *event) {
	if binding, ok := c.subscriptions[msg.Subscription]; ok {
		if e := softCumin(binding.expectedTypes, msg.Arguments); e == nil {
			c.Delegate.Invoke(c.name, msg.Subscription, msg.Arguments, msg.ArgumentsKw)
		} else {

			tosend := &errorMessage{
				Type:      pUBLISH,
				Request:   msg.Subscription,
				Details:   make(map[string]interface{}),
				Arguments: make([]interface{}, 0),
				Error:     e.Error(),
			}

			if err := c.honcho.Send(tosend); err != nil {
				log.Println("error sending message:", err)
			}
		}
	} else {
		log.Println("WARN: no handler registered for subscription:", msg.Subscription)
	}
}

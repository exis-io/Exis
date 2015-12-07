package coreRiffle

import (
	"fmt"
	"log"
)

type domain struct {
	Delegate
	app           *app
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
		app:           s.app,
		name:          s.name + "." + name,
		joined:        s.joined,
		subscriptions: make(map[uint]*boundEndpoint),
		registrations: make(map[uint]*boundEndpoint),
	}
}

// Accepts a connection that has just been opened. This method should only
// be called once, to initialize the fabric
func (c domain) Join(conn Connection) error {
	if c.joined {
		return fmt.Errorf("Domain %s is already joined", c.name)
	}

	// check to make sure the connection is not already set
	c.app.Connection = conn

	// Should we hard close on conn.Close()? The Head App may be interested in knowing about the close
	if err := c.app.SendNow(&hello{Realm: c.name, Details: map[string]interface{}{}}); err != nil {
		c.app.Close("ERR: could not send a hello message")
		return err
	}

	if msg, err := c.app.getMessageTimeout(); err != nil {
		c.app.Close(err.Error())
		return err
	} else if _, ok := msg.(*welcome); !ok {
		c.app.SendNow(&abort{Details: map[string]interface{}{}, Reason: "Error- unexpected_message_type"})
		c.app.Close("Error- unexpected_message_type")
		return fmt.Errorf(formatUnexpectedMessage(msg, wELCOME.String()))
	}

	go c.app.receiveLoop()
	go c.app.sendLoop()

	c.app.domainJoined(&c)
	Info("Domain joined")
	return nil
}

func (c domain) Leave() error {
	return c.app.domainLeft(&c)
}

/////////////////////////////////////////////
// Message Patterns
/////////////////////////////////////////////

// Subscribe registers the EventHandler to be called for every message in the provided endpoint.
func (c domain) Subscribe(endpoint string, types []interface{}) (uint, error) {
	endpoint = makeEndpoint(c.name, endpoint)

	sub := &subscribe{Request: newID(), Options: make(map[string]interface{}), Name: endpoint}

	if msg, err := c.app.requestListen(sub); err != nil {
		return 0, err
	} else if subbed, ok := msg.(*subscribed); !ok {
		return 0, fmt.Errorf(formatUnexpectedMessage(msg, sUBSCRIBED.String()))
	} else {
		Info("Subscribed: %s", endpoint)
		c.subscriptions[subbed.Subscription] = &boundEndpoint{endpoint, types}
		return subbed.Subscription, nil
	}
}

func (c domain) Register(endpoint string, types []interface{}) (uint, error) {
	endpoint = makeEndpoint(c.name, endpoint)

	register := &register{Request: newID(), Options: make(map[string]interface{}), Name: endpoint}

	if msg, err := c.app.requestListen(register); err != nil {
		return 0, err
	} else if reg, ok := msg.(*registered); !ok {
		return 0, fmt.Errorf(formatUnexpectedMessage(msg, rEGISTERED.String()))
	} else {
		Info("Registered: %s", endpoint)
		c.registrations[reg.Registration] = &boundEndpoint{endpoint, types}
		return reg.Registration, nil
	}
}

// Publish publishes an eVENT to all subscribed peers.
func (c domain) Publish(endpoint string, args []interface{}) error {
	endpoint = makeEndpoint(c.name, endpoint)

	return c.app.Send(&publish{
		Request:   newID(),
		Options:   make(map[string]interface{}),
		Name:      endpoint,
		Arguments: args,
	})
}

// Call calls a procedure given a URI.
func (c domain) Call(endpoint string, args []interface{}) ([]interface{}, error) {
	endpoint = makeEndpoint(c.name, endpoint)
	call := &call{Request: newID(), Name: endpoint, Options: make(map[string]interface{}), Arguments: args}

	// Testing out a shorter way of checking the return types of the messages-- be careful with this, untested
	if msg, err := c.app.requestListenType(call, "*coreRiffle.result"); err != nil {
		return nil, err
	} else {
		return msg.(*result).Arguments, nil
	}
}

// Unsubscribe removes the registered EventHandler from the endpoint.
func (c domain) Unsubscribe(endpoint string) error {
	endpoint = makeEndpoint(c.name, endpoint)
	subscriptionID, _, ok := bindingForEndpoint(c.subscriptions, endpoint)

	if !ok {
		return fmt.Errorf("domain %s is not registered with this client.", endpoint)
	}

	sub := &unsubscribe{Request: newID(), Subscription: subscriptionID}

	if _, err := c.app.requestListenType(sub, "*coreRiffle.unsubscribed"); err != nil {
		return err
	} else {
		Info("Unsubscribed: %s", endpoint)
		delete(c.subscriptions, subscriptionID)
		return nil
	}
}

// Unregister removes a procedure with the Node
func (c domain) Unregister(endpoint string) error {
	endpoint = makeEndpoint(c.name, endpoint)

	if procedureID, _, ok := bindingForEndpoint(c.registrations, endpoint); !ok {
		return fmt.Errorf("domain %s is not registered with this domain.", endpoint)
	} else {
		unregister := &unregister{Request: newID(), Registration: procedureID}

		if msg, err := c.app.requestListen(unregister); err != nil {
			return err
		} else if _, ok := msg.(*unregistered); !ok {
			return fmt.Errorf(formatUnexpectedMessage(msg, uNREGISTERED.String()))
		} else {
			Info("Unregistered: %s", endpoint)
			delete(c.registrations, procedureID)
			return nil
		}
	}
}

func (c domain) handleInvocation(msg *invocation) {
	if binding, ok := c.registrations[msg.Registration]; ok {
		go func() {
			// Check the return types
			if err := softCumin(binding.expectedTypes, msg.Arguments); err == nil {

				// Catch the error-- that has the cuminication information
				c.Delegate.Invoke(c.name, msg.Registration, msg.Arguments)
			} else {
				tosend := &errorMessage{
					Type:      iNVOCATION,
					Request:   msg.Request,
					Details:   make(map[string]interface{}),
					Arguments: msg.Arguments,
					Error:     err.Error(),
				}

				if err := c.app.Send(tosend); err != nil {
					log.Println("error sending message:", err)
				}
			}

			// Careful-- we can't yield in some languages. Have to implement the yield as a seperate function
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

			// if err := c.app.Send(tosend); err != nil {
			// 	log.Println("error sending message:", err)
			// }
		}()
	} else {
		s := fmt.Sprintf("no handler for registration: %v", msg.Registration)
		m := &errorMessage{Type: iNVOCATION, Request: msg.Request, Details: make(map[string]interface{}), Error: s}
		if err := c.app.Send(m); err != nil {
			log.Println("error sending message:", err)
		}
	}
}

func (c *domain) handlePublish(msg *event) {
	if binding, ok := c.subscriptions[msg.Subscription]; ok {
		if e := softCumin(binding.expectedTypes, msg.Arguments); e == nil {
			c.Delegate.Invoke(c.name, msg.Subscription, msg.Arguments)
		} else {

			tosend := &errorMessage{Type: pUBLISH, Request: msg.Subscription, Details: make(map[string]interface{}), Arguments: make([]interface{}, 0), Error: e.Error()}

			if err := c.app.Send(tosend); err != nil {
				log.Println("error sending message:", err)
			}
		}
	} else {
		log.Println("WARN: no handler registered for subscription:", msg.Subscription)
	}
}

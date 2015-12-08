package core

import "fmt"

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

func (d domain) Subdomain(name string, delegate Delegate) Domain {
	return d.app.NewDomain(d.name+"."+name, delegate)
}

// Accepts a connection that has just been opened. This method should only
// be called once, to initialize the fabric
func (c domain) Join(conn Connection) error {
	if c.joined {
		return fmt.Errorf("Domain %s is already joined", c.name)
	}

	// check to make sure the connection is not already set?
	c.app.Connection = conn

	// Should we hard close on conn.Close()? The App may be interested in knowing about the close
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

	// This is super dumb, and the reason its in here was fixed. Please revert
	go c.app.receiveLoop()
	go c.app.sendLoop()

	// old contents of app.join
	for _, x := range c.app.domains {
		if !x.joined {
			x.joined = true
			x.Delegate.OnJoin(x.name)
		}
	}

	Info("Domain joined")
	return nil
}

func (c *domain) Leave() error {
	// old contents of app.leave

	if dems, ok := removeDomain(c.app.domains, c); !ok {
		return fmt.Errorf("WARN: couldn't find %s to remove!", c)
	} else {
		c.app.domains = dems
	}

	if err := c.app.Send(&goodbye{
		Details: map[string]interface{}{},
		Reason:  ErrCloseRealm,
	}); err != nil {
		return fmt.Errorf("Error leaving fabric: %v", err)
	}

	// if no domains remain, terminate the connection
	if len(c.app.domains) == 0 {
		c.app.Close("Closing: no domains connected")
	}

	return nil
}

/////////////////////////////////////////////
// Message Patterns
/////////////////////////////////////////////

func (c domain) Subscribe(endpoint string, types []interface{}) (uint, error) {
	endpoint = makeEndpoint(c.name, endpoint)
	sub := &subscribe{Request: newID(), Options: make(map[string]interface{}), Name: endpoint}

	if msg, err := c.app.requestListenType(sub, "*core.subscribed"); err != nil {
		return 0, err
	} else {
		Info("Subscribed: %s", endpoint)
		subbed := msg.(*subscribed)
		c.subscriptions[subbed.Subscription] = &boundEndpoint{endpoint, types}
		return subbed.Subscription, nil
	}
}

func (c domain) Register(endpoint string, types []interface{}) (uint, error) {
	endpoint = makeEndpoint(c.name, endpoint)
	register := &register{Request: newID(), Options: make(map[string]interface{}), Name: endpoint}

	if msg, err := c.app.requestListenType(register, "*core.registered"); err != nil {
		return 0, err
	} else {
		Info("Registered: %s", endpoint)
		reg := msg.(*registered)
		c.registrations[reg.Registration] = &boundEndpoint{endpoint, types}
		return reg.Registration, nil
	}
}

func (c domain) Publish(endpoint string, args []interface{}) error {
	return c.app.Send(&publish{
		Request:   newID(),
		Options:   make(map[string]interface{}),
		Name:      makeEndpoint(c.name, endpoint),
		Arguments: args,
	})
}

func (c domain) Call(endpoint string, args []interface{}) ([]interface{}, error) {
	endpoint = makeEndpoint(c.name, endpoint)
	call := &call{Request: newID(), Name: endpoint, Options: make(map[string]interface{}), Arguments: args}

	if msg, err := c.app.requestListenType(call, "*core.result"); err != nil {
		return nil, err
	} else {
		return msg.(*result).Arguments, nil
	}
}

func (c domain) Unsubscribe(endpoint string) error {
	endpoint = makeEndpoint(c.name, endpoint)

	if id, _, ok := bindingForEndpoint(c.subscriptions, endpoint); !ok {
		return fmt.Errorf("domain %s is not registered with this client.", endpoint)
	} else {
		sub := &unsubscribe{Request: newID(), Subscription: id}

		if _, err := c.app.requestListenType(sub, "*core.unsubscribed"); err != nil {
			return err
		} else {
			Info("Unsubscribed: %s", endpoint)
			delete(c.subscriptions, id)
			return nil
		}
	}
}

func (c domain) Unregister(endpoint string) error {
	endpoint = makeEndpoint(c.name, endpoint)

	if id, _, ok := bindingForEndpoint(c.registrations, endpoint); !ok {
		return fmt.Errorf("domain %s is not registered with this domain.", endpoint)
	} else {
		unregister := &unregister{Request: newID(), Registration: id}

		if _, err := c.app.requestListenType(unregister, "*core.unregistered"); err != nil {
			return err
		} else {
			Info("Unregistered: %s", endpoint)
			delete(c.registrations, id)
			return nil
		}
	}
}

func (c domain) handleInvocation(msg *invocation, binding *boundEndpoint) {
	if err := softCumin(binding.expectedTypes, msg.Arguments); err == nil {
		c.Delegate.Invoke(msg.Registration, msg.Arguments)
	} else {
		tosend := &errorMessage{
			Type:      iNVOCATION,
			Request:   msg.Request,
			Details:   make(map[string]interface{}),
			Arguments: msg.Arguments,
			Error:     err.Error(),
		}

		if err := c.app.Send(tosend); err != nil {
			Warn("error sending message:", err)
		}
	}
}

func (c *domain) handlePublish(msg *event, binding *boundEndpoint) {
	if e := softCumin(binding.expectedTypes, msg.Arguments); e == nil {
		c.Delegate.Invoke(msg.Subscription, msg.Arguments)
	} else {

		tosend := &errorMessage{Type: pUBLISH, Request: msg.Subscription, Details: make(map[string]interface{}), Arguments: make([]interface{}, 0), Error: e.Error()}

		if err := c.app.Send(tosend); err != nil {
			Warn("error sending message:", err)
		}
	}

}

// We cant yield anymore!
// Careful-- we can't yield in some languages. Have to implement the yield as a seperate function
// var tosend message

// tosend = &yield{
//  Request:   msg.Request,
//  Options:   make(map[string]interface{}),
//  Arguments: result,
// }

// if err != nil {
//  tosend = &errorMessage{
//      Type:      iNVOCATION,
//      Request:   msg.Request,
//      Details:   make(map[string]interface{}),
//      Arguments: result,
//      Error:     err.Error(),
//  }
// }

// if err := c.app.Send(tosend); err != nil {
//  log.Println("error sending message:", err)
// }

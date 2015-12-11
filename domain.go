package core

import "fmt"

type Domain interface {
	Subscribe(string, uint, []interface{}) error
	Register(string, uint, []interface{}) error
	Publish(string, uint, []interface{}) error
	Call(string, uint, []interface{}) error

	Yield(uint, []interface{})

	Unsubscribe(string) error
	Unregister(string) error

	Join(Connection) error
	Leave() error
}

type domain struct {
	app           *app
	name          string
	joined        bool
	subscriptions map[uint]*boundEndpoint
	registrations map[uint]*boundEndpoint
}

type boundEndpoint struct {
	callback      uint
	endpoint      string
	expectedTypes []interface{}
}

func (d domain) Subdomain(name string) Domain {
	return d.app.NewDomain(d.name + "." + name)
}

// Accepts a connection that has just been opened. This method should only
// be called once, to initialize the fabric
func (c domain) Join(conn Connection) error {
	if c.joined {
		return fmt.Errorf("Domain %s is already joined", c.name)
	}

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
			// x.Delegate.OnJoin(x.name)
			// Invoke the onjoin method for the domain!
		}
	}

	Info("Domain joined")
	return nil
}

func (c *domain) Leave() error {
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

func (c domain) Subscribe(endpoint string, requestId uint, types []interface{}) error {
	endpoint = makeEndpoint(c.name, endpoint)
	sub := &subscribe{Request: NewID(), Options: make(map[string]interface{}), Name: endpoint}

	if msg, err := c.app.requestListenType(sub, "*core.subscribed"); err != nil {
		return err
	} else {
		subbed := msg.(*subscribed)
		Info("Subscribed: %s", endpoint)
		c.subscriptions[subbed.Subscription] = &boundEndpoint{requestId, endpoint, types}
		return nil
	}
}

func (c domain) Register(endpoint string, requestId uint, types []interface{}) error {
	endpoint = makeEndpoint(c.name, endpoint)
	register := &register{Request: requestId, Options: make(map[string]interface{}), Name: endpoint}

	if msg, err := c.app.requestListenType(register, "*core.registered"); err != nil {
		return err
	} else {
		Info("Registered: %s", endpoint)
		reg := msg.(*registered)
		c.registrations[reg.Registration] = &boundEndpoint{requestId, endpoint, types}
		return nil
	}
}

func (c domain) Publish(endpoint string, requestId uint, args []interface{}) error {
	return c.app.Send(&publish{
		Request:   NewID(),
		Options:   make(map[string]interface{}),
		Name:      makeEndpoint(c.name, endpoint),
		Arguments: args,
	})
}

func (c domain) Call(endpoint string, requestId uint, args []interface{}) error {
	endpoint = makeEndpoint(c.name, endpoint)
	call := &call{Request: NewID(), Name: endpoint, Options: make(map[string]interface{}), Arguments: args}

	if msg, err := c.app.requestListenType(call, "*core.result"); err != nil {
		return err
	} else {
		c.app.CallbackSend(requestId, msg.(*result).Arguments...)
		return nil
	}
}

func (c domain) Yield(request uint, args []interface{}) {
	// Big todo here
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

	if err := c.app.Send(m); err != nil {
		Warn("Could not send yield")
	} else {
		Info("Yield: %s", m)
	}
}

// This isn't going to work on the callback chain... no request id passed in
func (c domain) Unsubscribe(endpoint string) error {
	endpoint = makeEndpoint(c.name, endpoint)

	if id, _, ok := bindingForEndpoint(c.subscriptions, endpoint); !ok {
		return fmt.Errorf("domain %s is not registered with this client.", endpoint)
	} else {
		sub := &unsubscribe{Request: NewID(), Subscription: id}

		if _, err := c.app.requestListenType(sub, "*core.unsubscribed"); err != nil {
			return err
		} else {
			Info("Unsubscribed: %s", endpoint)
			delete(c.subscriptions, id)
			return nil
		}
	}
}

// Same as above -- won't work on the callbacks
func (c domain) Unregister(endpoint string) error {
	endpoint = makeEndpoint(c.name, endpoint)

	if id, _, ok := bindingForEndpoint(c.registrations, endpoint); !ok {
		return fmt.Errorf("domain %s is not registered with this domain.", endpoint)
	} else {
		unregister := &unregister{Request: NewID(), Registration: id}

		if _, err := c.app.requestListenType(unregister, "*core.unregistered"); err != nil {
			return err
		} else {
			Info("Unregistered: %s", endpoint)
			delete(c.registrations, id)
			return nil
		}
	}
}

// This blocks on the invoke. Does the goroutine block waiting for the response?
func (c domain) handleInvocation(msg *invocation, binding *boundEndpoint) {
	Debug("Processing invocation: %s", msg)

	if err := softCumin(binding.expectedTypes, msg.Arguments); err == nil {
		// Debug("Cuminciation succeeded.")
		// c.Delegate.Invoke(binding.callback, msg.Arguments)
		c.app.CallbackSend(binding.callback, msg.Arguments...)
		// c.app.up <- Callback{binding.callback, msg.Arguments}
	} else {
		// Debug("Cuminication failed.")

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
	Debug("Processing publish: %s", msg)

	if e := softCumin(binding.expectedTypes, msg.Arguments); e == nil {
		// Debug("Cuminciation succeeded.")
		// c.Delegate.Invoke(binding.callback, msg.Arguments)
		// c.app.up <- Callback{binding.callback, msg.Arguments}
		c.app.CallbackSend(binding.callback, msg.Arguments...)
	} else {
		// Debug("Cuminication failed.")
		tosend := &errorMessage{Type: pUBLISH, Request: msg.Subscription, Details: make(map[string]interface{}), Arguments: make([]interface{}, 0), Error: e.Error()}

		if err := c.app.Send(tosend); err != nil {
			Warn("error sending message:", err)
		}
	}
}

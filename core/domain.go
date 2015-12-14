package core

import "fmt"

type Domain interface {
	Subdomain(string) Domain

	Subscribe(string, uint, []interface{}) error
	Register(string, uint, []interface{}) error
	Publish(string, uint, []interface{}) error
	Call(string, uint, []interface{}) error

	Unsubscribe(string) error
	Unregister(string) error

	Join(Connection) error
	Leave() error
	GetApp() App
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

// Create a new domain. If no superdomain is provided, creates an app as well
// If the app exists, has a connection, and is connected then immediately call onJoin on that domain
func NewDomain(name string, a *app) Domain {
	Debug("Creating domain %s", name)

	if a == nil {
		a = &app{
			domains:    make([]*domain, 0),
			serializer: new(jSONSerializer),
			in:         make(chan message, 10),
			up:         make(chan Callback, 10),
			listeners:  make(map[uint]chan message),
		}
	}

	d := &domain{
		app:           a,
		name:          name,
		joined:        false,
		subscriptions: make(map[uint]*boundEndpoint),
		registrations: make(map[uint]*boundEndpoint),
	}

	// TODO: trigger onJoin if the superdomain has joined

	a.domains = append(a.domains, d)
	return d
}

func (d domain) Subdomain(name string) Domain {
	Debug("Creating subdomain %s", name)
	return NewDomain(d.name+"."+name, d.app)
}

func (d domain) GetApp() App {
	return d.app
}

// Accepts a connection that has just been opened. This method should only
// be called once, to initialize the fabric
func (c domain) Join(conn Connection) error {
	if c.joined {
		return fmt.Errorf("Domain %s is already joined", c.name)
	}

	// Handshake between the connection and the app
	c.app.Connection = conn
	conn.SetApp(c.app)

	// Set the agent string, or who WE are. When this domain leaves, termintate the connection
	c.app.agent = c.name

	// Should we hard close on conn.Close()? The App may be interested in knowing about the close
	if err := c.app.Send(&hello{Realm: c.name, Details: map[string]interface{}{}}); err != nil {
		c.app.Close("ERR: could not send a hello message")
		return err
	}

	if msg, err := c.app.getMessageTimeout(); err != nil {
		c.app.Close(err.Error())
		return err
	} else if _, ok := msg.(*welcome); !ok {
		c.app.Send(&abort{Details: map[string]interface{}{}, Reason: "Error- unexpected_message_type"})
		c.app.Close("Error- unexpected_message_type")
		return fmt.Errorf(formatUnexpectedMessage(msg, wELCOME.String()))
	}

	// This is super dumb, and the reason its in here was fixed. Please revert
	go c.app.receiveLoop()

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
	for _, v := range c.registrations {
		c.Unregister(v.endpoint)
	}

	for _, v := range c.subscriptions {
		c.Unsubscribe(v.endpoint)
	}

	if dems, ok := removeDomain(c.app.domains, c); !ok {
		return fmt.Errorf("WARN: couldn't find %s to remove!", c)
	} else {
		c.app.domains = dems
	}

	// if no domains remain, terminate the connection
	if len(c.app.domains) == 0 || c.app.agent == c.name {
		c.app.Close("No domains connected")
	}

	// Trigger closing callbacks

	return nil
}

/////////////////////////////////////////////
// Message Patterns
/////////////////////////////////////////////

// Apply the arguments to the given function on this domain.
// Accepts a list of arguments and a list of types for cuminication
// func (c domain) apply(fn func(string, uint, []interface{}), endpoint string, cb uint, eb uint) {
// 	// TODO: Validate endpoint, else errback
// 	endpoint = makeEndpoint(c.name, endpoint)

// 	// with function Subscribe:
// 	if e := fn(&c, endpoint, cb); e != nil {
// 		// If the function returns an error, err it back immediately
// 	}

// 	// Note that the above won't work for unsubscribe and unregister, since their success case returns nil
// }

func (c domain) Subscribe(endpoint string, requestId uint, types []interface{}) error {
	endpoint = makeEndpoint(c.name, endpoint)
	sub := &subscribe{Request: requestId, Options: make(map[string]interface{}), Name: endpoint}

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
	call := &call{Request: requestId, Name: endpoint, Options: make(map[string]interface{}), Arguments: args}

	if msg, err := c.app.requestListenType(call, "*core.result"); err != nil {
		return err
	} else {
		// No cumin here?
		c.app.CallbackSend(requestId, msg.(*result).Arguments...)		
		return nil
	}
}

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

func (c domain) handleInvocation(msg *invocation, binding *boundEndpoint) {
	if err := softCumin(binding.expectedTypes, msg.Arguments); err == nil {
		c.app.CallbackSend(binding.callback, append([]interface{}{msg.Request}, msg.Arguments...)...)
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
		c.app.CallbackSend(binding.callback, msg.Arguments...)
	} else {
		tosend := &errorMessage{Type: pUBLISH, Request: msg.Subscription, Details: make(map[string]interface{}), Arguments: make([]interface{}, 0), Error: e.Error()}

		if err := c.app.Send(tosend); err != nil {
			Warn("error sending message:", err)
		}
	}
}

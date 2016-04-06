package core

import (
	"fmt"
	"sync"
)

type Domain interface {
	Subdomain(string) Domain
	LinkDomain(string) Domain

	Subscribe(string, uint64, []interface{}, map[string]interface{}) error
	Register(string, uint64, []interface{}, map[string]interface{}) error
	Publish(string, []interface{}, map[string]interface{}) error
	Call(string, []interface{}, map[string]interface{}) ([]interface{}, error)

	Unsubscribe(string) error
	Unregister(string) error

	CallExpects(uint64, []interface{})
	GetCallExpect(uint64) ([]interface{}, bool)
	RemoveCallExpect(uint64)

	Join(Connection) error
	Leave() error
	GetApp() App
	GetName() string
}

type domain struct {
	app               *app
	name              string
	joined            bool
	subscriptions     map[uint64]*boundEndpoint
	registrations     map[uint64]*boundEndpoint
	handlers          map[uint64]*boundEndpoint // generalized handlers for other purposes
	callResponseTypes map[uint64][]interface{}
	subLock           sync.RWMutex
	regLock           sync.RWMutex
}

type boundEndpoint struct {
	callback      uint64
	endpoint      string
	expectedTypes []interface{}
}

// Create a new domain. If no superdomain is provided, creates an app as well
// If the app exists, has a connection, and is connected then immediately call onJoin on that domain
func NewDomain(name string, a *app) Domain {
	Debug("Creating domain %s", name)

	if a == nil {
		a = NewApp()
	}

	d := &domain{
		app:               a,
		name:              name,
		joined:            false,
		subscriptions:     make(map[uint64]*boundEndpoint),
		registrations:     make(map[uint64]*boundEndpoint),
		handlers:          make(map[uint64]*boundEndpoint),
		callResponseTypes: make(map[uint64][]interface{}),
	}

	// TODO: trigger onJoin if the superdomain has joined

	a.domains = append(a.domains, d)
	return d
}

func (d domain) Subdomain(name string) Domain {
	if name == "" {
		return NewDomain(d.name, d.app)
	} else {
		return NewDomain(d.name+"."+name, d.app)
	}
}

func (d domain) LinkDomain(name string) Domain {
	return NewDomain(name, d.app)
}

func (d domain) GetApp() App {
	return d.app
}

func (d domain) GetName() string {
	return d.name
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
	c.app.open = true

	// Set the agent string, or who WE are. When this domain leaves, termintate the connection
	c.app.agent = c.name

	err := c.app.SendHello()
	if err != nil {
		c.app.Close("ERR: could not send a hello message")
		return err
	}

	receivedWelcome := false
	for !receivedWelcome {
		msg, err := c.app.getMessageTimeout()
		if err != nil {
			c.app.Close(err.Error())
			return err
		}

		switch msg := msg.(type) {
		case *welcome:
			receivedWelcome = true
		case *challenge:
			c.app.handleChallenge(msg)
		default:
			c.app.Send(&abort{Details: map[string]interface{}{}, Reason: "Error- unexpected_message_type"})
			c.app.Close("Error- unexpected_message_type")
			return fmt.Errorf(formatUnexpectedMessage(msg, wELCOME.String()))
		}
	}

	c.app.SetState(Ready)

	// This is super dumb, and the reason its in here was fixed. Please revert
	go c.app.receiveLoop()

	// old contents of app.join. This functionality isn't needed anymore. Please revert
	for _, x := range c.app.domains {
		if !x.joined {
			x.joined = true
		}
	}

	Info("Domain %s joined", c.name)
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
		return fmt.Errorf("WARN: couldn't find %v to remove!", c)
	} else {
		c.app.domains = dems
	}

	// if no domains remain, terminate the connection
	if len(c.app.domains) == 0 || c.app.agent == c.name {
		c.app.Close("No domains connected")
	}

	// TODO: If the domain representing the agent name leaves, should the entire conection be taken down?

	// TODO: Trigger closing callbacks in the crust as needed
	return nil
}

/////////////////////////////////////////////
// Message Patterns
/////////////////////////////////////////////

func (c domain) Subscribe(endpoint string, requestId uint64, types []interface{}, options map[string]interface{}) error {
	endpoint = makeEndpoint(c.name, endpoint)
	sub := &subscribe{Request: requestId, Options: options, Name: endpoint}

	if msg, err := c.app.requestListenType(sub, "*core.subscribed"); err != nil {
		return err
	} else {
		Info("Subscribed: %s %v", endpoint, types)
		subbed := msg.(*subscribed)
		c.subLock.Lock()
		c.subscriptions[subbed.Subscription] = &boundEndpoint{requestId, endpoint, types}
		c.subLock.Unlock()
		return nil
	}
}

func (c domain) Register(endpoint string, requestId uint64, types []interface{}, options map[string]interface{}) error {
	endpoint = makeEndpoint(c.name, endpoint)
	options = c.ProcessOptions(requestId, options)
	register := &register{Request: requestId, Options: options, Name: endpoint}

	if msg, err := c.app.requestListenType(register, "*core.registered"); err != nil {
		return err
	} else {
		Info("Registered: %s %v", endpoint, types)
		reg := msg.(*registered)
		c.regLock.Lock()
		c.registrations[reg.Registration] = &boundEndpoint{requestId, endpoint, types}
		c.regLock.Unlock()
		return nil
	}
}

// TODO: ask for a Publish Suceeded all the times, so we can trigger callbacks
func (c domain) Publish(endpoint string, args []interface{}, options map[string]interface{}) error {
	endpoint = makeEndpoint(c.name, endpoint)
	Info("Publish %s %v", endpoint, args)

	c.app.Queue(&publish{
		Request:   NewID(),
		Options:   options,
		Name:      endpoint,
		Arguments: args,
	})

	return nil
}

func (c domain) Call(endpoint string, args []interface{}, options map[string]interface{}) ([]interface{}, error) {
	id := NewID()
	endpoint = makeEndpoint(c.name, endpoint)
	options = c.ProcessOptions(id, options)
	call := &call{Request: id, Name: endpoint, Options: options, Arguments: args}
	Info("Calling %s %v", endpoint, args)

	// This is a call, so setup to listen for a yield message with our return values
	if msg, err := c.app.requestListenType(call, "*core.result"); err != nil {
		return nil, err
	} else {
		return msg.(*result).Arguments, nil
	}
}

// Handles any generalized intialization that has to happen before options pass through
func (c domain) ProcessOptions(requestId uint64, options map[string]interface{}) map[string]interface{} {
	// If the key exists, the value is the handler id. Replace it with "true" and set up the handler
	if id, ok := options["progress"]; ok {
		handlerId := id.(uint64)
		options["progress"] = true

		// TODO: dont just pass the handler id, pass the types too for cumin enforcement
		c.handlers[requestId] = &boundEndpoint{handlerId, "", nil}
	}

	if options == nil {
		options = make(map[string]interface{})
	}

	return options
}

func (c domain) Unsubscribe(endpoint string) error {
	endpoint = makeEndpoint(c.name, endpoint)

	c.subLock.RLock()
	if id, _, ok := bindingForEndpoint(c.subscriptions, endpoint); !ok {
		c.subLock.RUnlock()
		return fmt.Errorf("domain %s is not registered with this client.", endpoint)
	} else {
		c.subLock.RUnlock()
		sub := &unsubscribe{Request: NewID(), Subscription: id}

		if _, err := c.app.requestListenType(sub, "*core.unsubscribed"); err != nil {
			return err
		} else {
			Info("Unsubscribed: %s", endpoint)
			c.subLock.Lock()
			delete(c.subscriptions, id)
			c.subLock.Unlock()
			return nil
		}
	}
}

func (c domain) Unregister(endpoint string) error {
	endpoint = makeEndpoint(c.name, endpoint)

	c.regLock.RLock()
	if id, _, ok := bindingForEndpoint(c.registrations, endpoint); !ok {
		c.regLock.RUnlock()
		return fmt.Errorf("domain %s is not registered with this domain.", endpoint)
	} else {
		c.regLock.RUnlock()
		unregister := &unregister{Request: NewID(), Registration: id}

		if _, err := c.app.requestListenType(unregister, "*core.unregistered"); err != nil {
			return err
		} else {
			Info("Unregistered: %s", endpoint)
			c.regLock.Lock()
			delete(c.registrations, id)
			c.regLock.Unlock()
			return nil
		}
	}
}

func (c domain) handleInvocation(msg *invocation, binding *boundEndpoint) {
	if err := SoftCumin(binding.expectedTypes, msg.Arguments); err == nil {
		c.app.CallbackSend(binding.callback, append([]interface{}{msg.Request}, msg.Arguments...)...)
	} else {
		errorArguments := make([]interface{}, 0)
		errorArguments = append(errorArguments, err.Error())

		tosend := &errorMessage{
			Type:      iNVOCATION,
			Request:   msg.Request,
			Details:   make(map[string]interface{}),
			Arguments: errorArguments,
			Error:     ErrInvalidArgument,
		}

		c.app.Queue(tosend)
	}
}

func (c *domain) handlePublish(msg *event, binding *boundEndpoint) {
	if err := SoftCumin(binding.expectedTypes, msg.Arguments); err == nil {
		c.app.CallbackSend(binding.callback, msg.Arguments...)
	} else {
		// TODO: warn application level code at some well-known location
		Warn("%v", err)
	}
}

// Only called as the result of a progressive result callback. The final call return
// is processed normally
func (c *domain) handleResult(msg *result, binding *boundEndpoint) {
	if err := SoftCumin(binding.expectedTypes, msg.Arguments); err == nil {
		c.app.CallbackSend(binding.callback, msg.Arguments...)
	} else {
		// TODO: warn application level code at some well-known location
		Warn("%v", err)
	}
}

// Adds the types to this domains expectant calls. As written, this method is potentially
// unsafe-- no way to check if the call really went out, which could leave the types in there forever
func (c domain) CallExpects(id uint64, types []interface{}) {
	c.callResponseTypes[id] = types
}

func (c domain) GetCallExpect(id uint64) ([]interface{}, bool) {
	types, ok := c.callResponseTypes[id]
	return types, ok
}

func (c domain) RemoveCallExpect(id uint64) {
	delete(c.callResponseTypes, id)
}

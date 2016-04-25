package core

import "fmt"

type Domain interface {
	Subdomain(string, uint64, uint64) Domain
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

	Join() error
	Leave() error

	GetApp() App
	GetName() string
}

type domain struct {
	app               *app
	name              string
	joined            bool
	onJoin            uint64
	onLeave           uint64
	subscriptions     BindingConcurrentMap
	registrations     BindingConcurrentMap
	handlers          BindingConcurrentMap // generalized handlers for other purposes
	callResponseTypes map[uint64][]interface{}
}

type boundEndpoint struct {
	callback      uint64
	endpoint      string
	expectedTypes []interface{}
}

// Create a new domain. The handlers passed in are handlers for onLeave and onJoin, respectively
func (a *app) NewDomain(name string, joincb uint64, leavecb uint64) Domain {
	Debug("Creating domain %s", name)

	d := &domain{
		app:               a,
		name:              name,
		joined:            false,
		onJoin:            joincb,
		onLeave:           leavecb,
		subscriptions:     NewConcurrentBindingMap(),
		registrations:     NewConcurrentBindingMap(),
		handlers:          NewConcurrentBindingMap(),
		callResponseTypes: make(map[uint64][]interface{}),
	}

	a.domains = append(a.domains, d)
	return d
}

func (d domain) Subdomain(name string, joincb uint64, leavecb uint64) Domain {
	if name == "" {
		return d.app.NewDomain(d.name, joincb, leavecb)
	} else {
		return d.app.NewDomain(d.name+"."+name, joincb, leavecb)
	}
}

func (d domain) LinkDomain(name string) Domain {
	return d.app.NewDomain(name, 0, 0)
}

func (d domain) GetApp() App {
	return d.app
}

func (d domain) GetName() string {
	return d.name
}

// Join this domain, triggering its onJoin method
func (c domain) Join() error {
	if !c.app.open {
		return fmt.Errorf("Cant join while no connection is present")
	}

	c.joined = true
	c.app.CallbackSend(c.onJoin)

	return nil
}

// Disconnect this domain from the app connection. Removes all registrations
// and subscriptions from this domain and calls its crust onLeave method
func (c *domain) Leave() error {
	if !c.app.open {
		return fmt.Errorf("Cant leave while no connection is present")
	}

	for t := range c.registrations.Iter() {
		c.Unregister(t.Val.endpoint)
	}

	for t := range c.subscriptions.Iter() {
		c.Unsubscribe(t.Val.endpoint)
	}

	c.app.CallbackSend(c.onLeave)

	return nil
}

/////////////////////////////////////////////
// Message Patterns
/////////////////////////////////////////////

func (c domain) Subscribe(endpoint string, requestId uint64, types []interface{}, options map[string]interface{}) error {
	endpoint = makeEndpoint(c.name, endpoint)
	opts, optionsEndpoint := c.ProcessOptions(requestId, endpoint, options)
	sub := &subscribe{Request: requestId, Options: opts, Name: optionsEndpoint}

	if msg, err := c.app.requestListenType(sub, "*core.subscribed"); err != nil {
		return err
	} else {
		Info("Subscribed: %s %v", endpoint, types)
		subbed := msg.(*subscribed)
		c.subscriptions.Set(subbed.Subscription, &boundEndpoint{requestId, endpoint, types})
		return nil
	}
}

func (c domain) Register(endpoint string, requestId uint64, types []interface{}, options map[string]interface{}) error {
	endpoint = makeEndpoint(c.name, endpoint)
	options, optionsEndpoint := c.ProcessOptions(requestId, endpoint, options)
	register := &register{Request: requestId, Options: options, Name: optionsEndpoint}

	if msg, err := c.app.requestListenType(register, "*core.registered"); err != nil {
		return err
	} else {
		Info("Registered: %s %v", endpoint, types)
		reg := msg.(*registered)
		c.registrations.Set(reg.Registration, &boundEndpoint{requestId, endpoint, types})
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
	options, _ = c.ProcessOptions(id, endpoint, options)
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
// Returns a modified endpoint in the case of a details options
func (c domain) ProcessOptions(requestId uint64, endpoint string, options map[string]interface{}) (map[string]interface{}, string) {
	// If the key exists, the value is the handler id. Replace it with "true" and set up the handler
	if id, ok := options["progress"]; ok {
		handlerId := id.(uint64)
		options["progress"] = true

		// TODO: dont just pass the handler id, pass the types too for cumin enforcement
		c.handlers.Set(requestId, &boundEndpoint{handlerId, "", nil})
	}

	// This is a hack leftover from the original swift implementation
	if details, ok := options["details"]; ok && details.(bool) == true {
		endpoint = endpoint + "#details"
	}

	if options == nil {
		options = make(map[string]interface{})
	}

	return options, endpoint
}

func (c domain) Unsubscribe(endpoint string) error {
	endpoint = makeEndpoint(c.name, endpoint)

	if id, _, ok := c.subscriptions.GetWithEndpoint(endpoint); !ok {
		return fmt.Errorf("domain %s is not registered with this client.", endpoint)
	} else {
		sub := &unsubscribe{Request: NewID(), Subscription: id}

		if _, err := c.app.requestListenType(sub, "*core.unsubscribed"); err != nil {
			return err
		} else {
			Info("Unsubscribed: %s", endpoint)
			c.subscriptions.RemoveKey(id)
			return nil
		}
	}
}

func (c domain) Unregister(endpoint string) error {
	endpoint = makeEndpoint(c.name, endpoint)

	if id, _, ok := c.registrations.GetWithEndpoint(endpoint); !ok {
		return fmt.Errorf("domain %s is not registered with this domain.", endpoint)
	} else {
		unregister := &unregister{Request: NewID(), Registration: id}

		if _, err := c.app.requestListenType(unregister, "*core.unregistered"); err != nil {
			return err
		} else {
			Info("Unregistered: %s", endpoint)
			c.registrations.RemoveKey(id)
			return nil
		}
	}
}

func (c domain) handleInvocation(msg *invocation, binding *boundEndpoint) {
	if err := SoftCumin(binding.expectedTypes, msg.Arguments); err == nil {
		Info("Calling %s", binding.endpoint)
		c.app.CallbackSend(binding.callback, append([]interface{}{msg.Request}, msg.Arguments...)...)
	} else {
		Info("Call failed: %s, %s", binding.endpoint, err.Error())
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
		Info("Publishing %s", binding.endpoint)
		c.app.CallbackSend(binding.callback, msg.Arguments...)
	} else {
		Warn("%v", err)
	}
}

// Only called as the result of a progressive result callback. The final call return
// is processed normally
func (c *domain) handleResult(msg *result, binding *boundEndpoint) {
	if err := SoftCumin(binding.expectedTypes, msg.Arguments); err == nil {
		c.app.CallbackSend(binding.callback, msg.Arguments...)
	} else {
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

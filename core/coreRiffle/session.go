package riffle

import (
	"fmt"
	"log"
	"time"

	"github.com/gorilla/websocket"
)

type Session struct {
	Connection
	ReceiveTimeout time.Duration
	Auth           map[string]AuthFunc
	ReceiveDone    chan bool
	listeners      map[uint]chan Message
	events         map[uint]*boundEndpoint
	procedures     map[uint]*boundEndpoint
	requestCount   uint
	pdid           string
}

type boundEndpoint struct {
	endpoint string
	handler  interface{}
}

// Connect to the node with the given URL
func Start(url string, domain string) (*Session, error) {
	dialer := websocket.Dialer{Subprotocols: []string{"wamp.2.json"}}

	conn, _, err := dialer.Dial(url, nil)

	if err != nil {
		return nil, err
	}

	connection := &websocketConnection{
		conn:        conn,
		messages:    make(chan Message, 10),
		serializer:  new(JSONSerializer),
		payloadType: websocket.TextMessage,
	}

	if err != nil {
		return nil, err
	}

	go connection.run()

	client := &Session{
		Connection:     connection,
		ReceiveTimeout: 10 * time.Second,
		listeners:      make(map[uint]chan Message),
		events:         make(map[uint]*boundEndpoint),
		procedures:     make(map[uint]*boundEndpoint),
		requestCount:   0,
	}

	client.JoinRealm(domain, nil)
	return client, nil
}

// Receive handles messages from the server until this client disconnects.
// This function blocks and is most commonly run in a goroutine.
func (c *Session) Receive() {
	for msg := range c.Connection.Receive() {

		switch msg := msg.(type) {

		case *Event:
			if event, ok := c.events[msg.Subscription]; ok {
				go Cumin(event.handler, msg.Arguments)
			} else {
				log.Println("no handler registered for subscription:", msg.Subscription)
			}

		case *Invocation:
			c.handleInvocation(msg)

		case *Registered:
			c.notifyListener(msg, msg.Request)
		case *Subscribed:
			c.notifyListener(msg, msg.Request)
		case *Unsubscribed:
			c.notifyListener(msg, msg.Request)
		case *Unregistered:
			c.notifyListener(msg, msg.Request)
		case *Result:
			c.notifyListener(msg, msg.Request)
		case *Error:
			c.notifyListener(msg, msg.Request)

		case *Goodbye:
			break

		default:
			log.Println("unhandled message:", msg.MessageType(), msg)
		}
	}

	if c.ReceiveDone != nil {
		c.ReceiveDone <- true
	}
}

/////////////////////////////////////////////
// Handler methods
/////////////////////////////////////////////

// Subscribe registers the EventHandler to be called for every message in the provided topic.
func (c *Session) Subscribe(topic string, fn interface{}) error {
	id := NewID()
	c.registerListener(id)

	sub := &Subscribe{
		Request: id,
		Options: make(map[string]interface{}),
		Domain:  topic,
	}

	if err := c.Send(sub); err != nil {
		return err
	}

	// wait to receive SUBSCRIBED message
	msg, err := c.waitOnListener(id)
	if err != nil {
		return err
	} else if e, ok := msg.(*Error); ok {
		return fmt.Errorf("error subscribing to topic '%v': %v", topic, e.Error)
	} else if subscribed, ok := msg.(*Subscribed); !ok {
		return fmt.Errorf(formatUnexpectedMessage(msg, SUBSCRIBED))
	} else {
		// register the event handler with this subscription
		c.events[subscribed.Subscription] = &boundEndpoint{topic, fn}
	}
	return nil
}

// Unsubscribe removes the registered EventHandler from the topic.
func (c *Session) Unsubscribe(topic string) error {
	subscriptionID, _, ok := bindingForEndpoint(c.events, topic)

	if !ok {
		return fmt.Errorf("Domain %s is not registered with this client.", topic)
	}

	id := NewID()
	c.registerListener(id)

	sub := &Unsubscribe{
		Request:      id,
		Subscription: subscriptionID,
	}

	if err := c.Send(sub); err != nil {
		return err
	}

	// wait to receive UNSUBSCRIBED message
	msg, err := c.waitOnListener(id)
	if err != nil {
		return err
	} else if e, ok := msg.(*Error); ok {
		return fmt.Errorf("error unsubscribing to topic '%v': %v", topic, e.Error)
	} else if _, ok := msg.(*Unsubscribed); !ok {
		return fmt.Errorf(formatUnexpectedMessage(msg, UNSUBSCRIBED))
	}

	delete(c.events, subscriptionID)
	return nil
}

func (c *Session) Register(procedure string, fn interface{}, options map[string]interface{}) error {
	id := NewID()
	c.registerListener(id)

	register := &Register{
		Request: id,
		Options: options,
		Domain:  procedure,
	}

	if err := c.Send(register); err != nil {
		return err
	}

	// wait to receive REGISTERED message
	msg, err := c.waitOnListener(id)
	if err != nil {
		return err
	} else if e, ok := msg.(*Error); ok {
		return fmt.Errorf("error registering procedure '%v': %v", procedure, e.Error)
	} else if registered, ok := msg.(*Registered); !ok {
		return fmt.Errorf(formatUnexpectedMessage(msg, REGISTERED))
	} else {
		// register the event handler with this registration
		c.procedures[registered.Registration] = &boundEndpoint{procedure, fn}
	}
	return nil
}

// Unregister removes a procedure with the Node
func (c *Session) Unregister(procedure string) error {
	procedureID, _, ok := bindingForEndpoint(c.procedures, procedure)

	if !ok {
		return fmt.Errorf("Domain %s is not registered with this client.", procedure)
	}

	id := NewID()
	c.registerListener(id)

	unregister := &Unregister{
		Request:      id,
		Registration: procedureID,
	}

	if err := c.Send(unregister); err != nil {
		return err
	}

	// wait to receive UNREGISTERED message
	msg, err := c.waitOnListener(id)
	if err != nil {
		return err
	} else if e, ok := msg.(*Error); ok {
		return fmt.Errorf("error unregister to procedure '%v': %v", procedure, e.Error)
	} else if _, ok := msg.(*Unregistered); !ok {
		return fmt.Errorf(formatUnexpectedMessage(msg, UNREGISTERED))
	}

	// register the event handler with this unregistration
	delete(c.procedures, procedureID)
	return nil
}

// Publish publishes an EVENT to all subscribed peers.
func (c *Session) Publish(endpoint string, args ...interface{}) error {
	return c.Send(&Publish{
		Request:   NewID(),
		Options:   make(map[string]interface{}),
		Domain:    endpoint,
		Arguments: args,
	})
}

// Call calls a procedure given a URI.
func (c *Session) Call(procedure string, args ...interface{}) ([]interface{}, error) {
	id := NewID()
	c.registerListener(id)

	call := &Call{
		Request:   id,
		Domain:    procedure,
		Options:   make(map[string]interface{}),
		Arguments: args,
	}

	if err := c.Send(call); err != nil {
		return nil, err
	}

	// wait to receive RESULT message
	msg, err := c.waitOnListener(id)
	if err != nil {
		return nil, err
	} else if e, ok := msg.(*Error); ok {
		return nil, fmt.Errorf("error calling procedure '%v': %v", procedure, e.Error)
	} else if result, ok := msg.(*Result); !ok {
		return nil, fmt.Errorf(formatUnexpectedMessage(msg, RESULT))
	} else {
		return result.Arguments, nil
	}
}

func (c *Session) Leave() error {
	if err := c.Send(goodbyeSession); err != nil {
		return fmt.Errorf("error leaving realm: %v", err)
	}

	if err := c.Connection.Close(); err != nil {
		return fmt.Errorf("error closing client connection: %v", err)
	}

	return nil
}

/////////////////////////////////////////////
// Misc
/////////////////////////////////////////////

// JoinRealm joins a WAMP realm, but does not handle challenge/response authentication.
func (c *Session) JoinRealm(realm string, details map[string]interface{}) (map[string]interface{}, error) {
	if details == nil {
		details = map[string]interface{}{}
	}

	if c.Auth != nil && len(c.Auth) > 0 {
		return c.joinRealmCRA(realm, details)
	}

	if err := c.Send(&Hello{Realm: realm, Details: details}); err != nil {
		c.Connection.Close()
		return nil, err
	}

	if msg, err := GetMessageTimeout(c.Connection, c.ReceiveTimeout); err != nil {
		c.Connection.Close()
		return nil, err
	} else if welcome, ok := msg.(*Welcome); !ok {
		c.Send(abortUnexpectedMsg)
		c.Connection.Close()
		return nil, fmt.Errorf(formatUnexpectedMessage(msg, WELCOME))
	} else {
		go c.Receive()
		return welcome.Details, nil
	}
}

// joinRealmCRA joins a WAMP realm and handles challenge/response authentication.
func (c *Session) joinRealmCRA(realm string, details map[string]interface{}) (map[string]interface{}, error) {
	authmethods := []interface{}{}
	for m := range c.Auth {
		authmethods = append(authmethods, m)
	}
	details["authmethods"] = authmethods
	if err := c.Send(&Hello{Realm: realm, Details: details}); err != nil {
		c.Connection.Close()
		return nil, err
	}
	if msg, err := GetMessageTimeout(c.Connection, c.ReceiveTimeout); err != nil {
		c.Connection.Close()
		return nil, err
	} else if challenge, ok := msg.(*Challenge); !ok {
		c.Send(abortUnexpectedMsg)
		c.Connection.Close()
		return nil, fmt.Errorf(formatUnexpectedMessage(msg, CHALLENGE))
	} else if authFunc, ok := c.Auth[challenge.AuthMethod]; !ok {
		c.Send(abortNoAuthHandler)
		c.Connection.Close()
		return nil, fmt.Errorf("no auth handler for method: %s", challenge.AuthMethod)
	} else if signature, authDetails, err := authFunc(details, challenge.Extra); err != nil {
		c.Send(abortAuthFailure)
		c.Connection.Close()
		return nil, err
	} else if err := c.Send(&Authenticate{Signature: signature, Extra: authDetails}); err != nil {
		c.Connection.Close()
		return nil, err
	}
	if msg, err := GetMessageTimeout(c.Connection, c.ReceiveTimeout); err != nil {
		c.Connection.Close()
		return nil, err
	} else if welcome, ok := msg.(*Welcome); !ok {
		c.Send(abortUnexpectedMsg)
		c.Connection.Close()
		return nil, fmt.Errorf(formatUnexpectedMessage(msg, WELCOME))
	} else {
		go c.Receive()
		return welcome.Details, nil
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

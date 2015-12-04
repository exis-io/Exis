package goriffle

import (
	"fmt"
	"log"
	"time"

	"github.com/gorilla/websocket"
)

type authFunc func(map[string]interface{}, map[string]interface{}) (string, map[string]interface{}, error)

type session struct {
	connection
	ReceiveTimeout time.Duration
	Auth           map[string]authFunc
	ReceiveDone    chan bool
	listeners      map[uint]chan message
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
func Start(url string, domain string) (*session, error) {

	// Part 1: could sub in directly here with "Dial" replacement
	// dialer := websocket.Dialer{Subprotocols: []string{"wamp.2.msgPack"}}
	// conn, _, err := dialer.Dial(url, nil)

	// if err != nil {
	// 	fmt.Println("Unable to dial connection!")
	// 	return nil, err
	// }

	// ws, err := jssock.New(url)

	// if err != nil {
	// 	fmt.Println("Unable to create js websocket")
	// }

	// ws.AddEventListener("message", false, jsHandle)
	// ws.AddEventListener("open", false, jsOpen)

	dialer := websocket.Dialer{Subprotocols: []string{"wamp.2.json"}}

	conn, _, err := dialer.Dial(url, nil)

	if err != nil {
		return nil, err
	}

	connection := &websocketConnection{
		conn: conn,
		// jsws:        ws,
		messages:    make(chan message, 10),
		serializer:  new(jSONSerializer),
		payloadType: websocket.TextMessage,
	}

	if err != nil {
		return nil, err
	}

	go connection.run()

	client := &session{
		connection:     connection,
		ReceiveTimeout: 1 * time.Second,
		listeners:      make(map[uint]chan message),
		events:         make(map[uint]*boundEndpoint),
		procedures:     make(map[uint]*boundEndpoint),
		requestCount:   0,
	}

	client.JoinRealm(domain, nil)
	return client, nil
}

// func jsHandle(a *js.Object) {
// 	fmt.Println("Message received: ", a)
// }

// func jsOpen(a *js.Object) {
// 	fmt.Println("Opened: ", a)
// }

// Receive handles messages from the server until this client disconnects.
// This function blocks and is most commonly run in a goroutine.
func (c *session) Receive() {
	for msg := range c.connection.Receive() {
		//fmt.Println("GR: Core MSG: ", msg)

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
			panic("Unhandled message!")
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
func (c *session) Subscribe(topic string, fn interface{}) error {
	id := newID()
	c.registerListener(id)

	sub := &subscribe{
		Request: id,
		Options: make(map[string]interface{}),
		Domain:  topic,
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
func (c *session) Unsubscribe(topic string) error {
	subscriptionID, _, ok := bindingForEndpoint(c.events, topic)

	if !ok {
		return fmt.Errorf("Domain %s is not registered with this client.", topic)
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

func (c *session) Register(procedure string, fn interface{}, options map[string]interface{}) error {
	id := newID()
	c.registerListener(id)

	register := &register{
		Request: id,
		Options: options,
		Domain:  procedure,
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
func (c *session) Unregister(procedure string) error {
	procedureID, _, ok := bindingForEndpoint(c.procedures, procedure)

	if !ok {
		return fmt.Errorf("Domain %s is not registered with this client.", procedure)
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
func (c *session) Publish(endpoint string, args ...interface{}) error {
	return c.Send(&publish{
		Request:   newID(),
		Options:   make(map[string]interface{}),
		Domain:    endpoint,
		Arguments: args,
	})
}

// Call calls a procedure given a URI.
func (c *session) Call(procedure string, args ...interface{}) ([]interface{}, error) {
	id := newID()
	c.registerListener(id)

	call := &call{
		Request:   id,
		Domain:    procedure,
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

func (c *session) Leave() error {
	if err := c.Send(goodbyeSession); err != nil {
		return fmt.Errorf("error leaving realm: %v", err)
	}

	if err := c.connection.Close(); err != nil {
		return fmt.Errorf("error closing client connection: %v", err)
	}

	return nil
}

func (c *session) handleInvocation(msg *invocation) {
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

/////////////////////////////////////////////
// Misc
/////////////////////////////////////////////

// JoinRealm joins a WAMP realm, but does not handle challenge/response authentication.
func (c *session) JoinRealm(realm string, details map[string]interface{}) (map[string]interface{}, error) {
	if details == nil {
		details = map[string]interface{}{}
	}

	if c.Auth != nil && len(c.Auth) > 0 {
		return c.joinRealmCRA(realm, details)
	}

	if err := c.Send(&hello{Realm: realm, Details: details}); err != nil {
		c.connection.Close()
		return nil, err
	}

	if msg, err := getMessageTimeout(c.connection, c.ReceiveTimeout); err != nil {
		c.connection.Close()
		return nil, err
	} else if welcome, ok := msg.(*welcome); !ok {
		c.Send(abortUnexpectedMsg)
		c.connection.Close()
		return nil, fmt.Errorf(formatUnexpectedMessage(msg, wELCOME))
	} else {
		//go c.Receive()
		return welcome.Details, nil
	}
}

// joinRealmCRA joins a WAMP realm and handles challenge/response authentication.
func (c *session) joinRealmCRA(realm string, details map[string]interface{}) (map[string]interface{}, error) {
	authmethods := []interface{}{}
	for m := range c.Auth {
		authmethods = append(authmethods, m)
	}
	details["authmethods"] = authmethods
	if err := c.Send(&hello{Realm: realm, Details: details}); err != nil {
		c.connection.Close()
		return nil, err
	}
	if msg, err := getMessageTimeout(c.connection, c.ReceiveTimeout); err != nil {
		c.connection.Close()
		return nil, err
	} else if challenge, ok := msg.(*challenge); !ok {
		c.Send(abortUnexpectedMsg)
		c.connection.Close()
		return nil, fmt.Errorf(formatUnexpectedMessage(msg, cHALLENGE))
	} else if authFunc, ok := c.Auth[challenge.AuthMethod]; !ok {
		c.Send(abortNoAuthHandler)
		c.connection.Close()
		return nil, fmt.Errorf("no auth handler for method: %s", challenge.AuthMethod)
	} else if signature, authDetails, err := authFunc(details, challenge.Extra); err != nil {
		c.Send(abortAuthFailure)
		c.connection.Close()
		return nil, err
	} else if err := c.Send(&authenticate{Signature: signature, Extra: authDetails}); err != nil {
		c.connection.Close()
		return nil, err
	}
	if msg, err := getMessageTimeout(c.connection, c.ReceiveTimeout); err != nil {
		c.connection.Close()
		return nil, err
	} else if welcome, ok := msg.(*welcome); !ok {
		c.Send(abortUnexpectedMsg)
		c.connection.Close()
		return nil, fmt.Errorf(formatUnexpectedMessage(msg, wELCOME))
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

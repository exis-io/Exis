package core

import (
	"encoding/json"
	"fmt"
	"os"
	"reflect"
	"sync"
	"time"
)

const (
	Disconnected = iota
	Connected
	Ready
	Leaving
)

// Exponential backoff settings
//
// initialRetryDelay is used for the first reconnection after startup and after
// a successful connection (0 means try again immediately).
//
// Subsequent retries will use delays that grow exponentially between
// minRetryDelay and maxRetryDelay.
const (
	initialRetryDelay = 0 * time.Second
	minRetryDelay     = 1 * time.Second
	maxRetryDelay     = 30 * time.Second
)

type App interface {
	ReceiveBytes([]byte)
	ReceiveMessage(message)

	Yield(uint64, []interface{})
	YieldError(uint64, string, []interface{})
	YieldOptions(request uint64, args []interface{}, options map[string]interface{})

	Close(string)
	ConnectionClosed(string)

	CallbackListen() Callback
	CallbackSend(uint64, ...interface{})

	SendHello() error

	// Temporary location, will move to security
	SetToken(string)
	GetToken() string

	Login(Domain, ...string) (Domain, error)
	RegisterAccount(Domain, string, string, string, string) (bool, error)

	SetState(int)
	ShouldReconnect() bool
	NextRetryDelay() time.Duration
}

type app struct {
	domains []*domain
	Connection
	serializer

	in   chan message
	out  chan message
	up   chan Callback
	open bool

	// Set to true if we are leaving.
	// It tells the lower layer not to try to reconnect.
	leaving bool

	state       int
	stateMutex  sync.Mutex
	stateChange *sync.Cond

	listeners     map[uint64]chan message
	listenersLock sync.Mutex

	// authentication options
	// TODO: store as a list of credentials
	// TODO: include username/password as a type
	agent  string
	authid string
	token  string
	key    string

	retryDelay time.Duration
}

// Sent up to the mantle and then the crust as callbacks are triggered
type Callback struct {
	Id   uint64
	Args []interface{}
}

func NewApp() *app {
	a := &app{
		domains:    make([]*domain, 0),
		serializer: new(jSONSerializer),
		open:       false,
		state:      Disconnected,
		in:         make(chan message, 10),
		out:        make(chan message, 10),
		up:         make(chan Callback, 10),
		listeners:  make(map[uint64]chan message),
		token:      "",
		retryDelay: initialRetryDelay,
	}

	a.stateChange = sync.NewCond(&a.stateMutex)

	go a.serviceOutgoingQueue()

	a.authid = os.Getenv("EXIS_AUTHID")
	a.token = os.Getenv("EXIS_TOKEN")
	a.key = os.Getenv("EXIS_KEY")

	return a
}

func (a *app) CallbackListen() Callback {
	m := <-a.up
	return m
}

func (a *app) CallbackSend(id uint64, args ...interface{}) {
	a.up <- Callback{id, args}
}

func (c *app) Send(m message) error {
	Debug("Sending %s: %v", m.messageType(), m)

	if !c.open {
		return fmt.Errorf("Could not send on closed connection")
	}

	if b, err := c.serializer.serialize(m); err != nil {
		return err
	} else {
		return c.Connection.Send(b)
	}
}

// Most messages should use this instead of Send.  It puts the message in an
// outgoing channel where they can wait until the underlying connection is able
// to deliver them.
//
// Control messages that should not be queued can be sent directly via Send.
func (c *app) Queue(m message) {
	c.out <- m
}

func (c *app) Close(reason string) {
	c.SetState(Leaving)
	c.leaving = true

	if !c.open {
		// TODO: JS calls close one to many times. Please stop it.
		// Warn("JS specific bandaid triggered!")
		return
	} else {
		Info("Closing internally: ", reason)
	}

	if err := c.Send(&goodbye{Details: map[string]interface{}{}, Reason: ErrCloseSession}); err != nil {
		Warn("Error sending goodbye: %v", err)
	}

	c.open = false
	//close(c.in)
	//close(c.up)
	c.in = make(chan message, 10)
	c.up = make(chan Callback, 10)

	// Theres some missing logic here when it comes to closing the external connection,
	// especially when either end could call and trigger a close
	c.Connection.Close(reason)
}

func (c *app) ConnectionClosed(reason string) {
	Info("Connection was closed: ", reason)
	c.open = false

	c.SetState(Disconnected)
}

// Send a Hello message to join the fabric.
// Assumes a.agent has been set appropriately.
func (a *app) SendHello() error {
	helloDetails := make(map[string]interface{})
	helloDetails["authid"] = a.getAuthID()
	helloDetails["authmethods"] = a.getAuthMethods()

	// Duct tape for js demo
	// if Fabric == FabricProduction && c.app.token == "" {
	//  Info("No token found on production. Attempting to auth from scratch")

	//  if token, err := tokenLogin(c.app.agent); err != nil {
	//      return err
	//  } else {
	//      c.app.token = token
	//  }
	// }

	msg := hello{
		Realm:   a.agent,
		Details: helloDetails,
	}

	return a.Send(&msg)
}

// Represents the result of an invokation in the crust
func (a *app) Yield(request uint64, args []interface{}) {
	m := &yield{
		Request:   request,
		Options:   make(map[string]interface{}),
		Arguments: args,
	}

	a.Queue(m)
}

func (a *app) YieldOptions(request uint64, args []interface{}, options map[string]interface{}) {
	m := &yield{
		Request:   request,
		Options:   options,
		Arguments: args,
	}

	a.Queue(m)
}

// Represents an error that ocurred during an invocation in the crust
func (a *app) YieldError(request uint64, etype string, args []interface{}) {
	m := &errorMessage{
		Type:      iNVOCATION,
		Request:   request,
		Details:   make(map[string]interface{}),
		Arguments: args,
		Error:     etype,
	}

	a.Queue(m)
}

func (c *app) receiveLoop() {
	for {
		if msg, open := <-c.in; !open {
			Debug("Receive loop close")
			break
		} else {
			Debug("Received %s: %v", msg.messageType(), msg)
			c.handle(msg)
		}
	}
}

// Handles an incoming message appropriately
func (c *app) handle(msg message) {
	switch msg := msg.(type) {

	case *challenge:
		go c.handleChallenge(msg)
		return

	case *event:
		for _, x := range c.domains {
			x.subLock.RLock()
			if binding, ok := x.subscriptions[msg.Subscription]; ok {
				x.subLock.RUnlock()
				go x.handlePublish(msg, binding)
				return
			} else {
				x.subLock.RUnlock()
			}
		}

		// We can't be delivered to a sub we don't have... right?
		Warn("No handler registered for subscription:", msg.Subscription)

	case *invocation:
		for _, x := range c.domains {
			x.regLock.RLock()
			if binding, ok := x.registrations[msg.Registration]; ok {
				x.regLock.RUnlock()
				go x.handleInvocation(msg, binding)
				return
			} else {
				x.regLock.RUnlock()
			}
		}

		s := fmt.Sprintf("no handler for registration: %v", msg.Registration)
		Warn(s)

		m := &errorMessage{
			Type:    iNVOCATION,
			Request: msg.Request,
			Details: make(map[string]interface{}),
			Error:   ErrNoSuchRegistration,
		}

		c.Queue(m)

	// Handle call results seperately to account for progressive calls
	case *result:
		c.findListener(msg)

	case *welcome:
		Debug("Received WELCOME, reestablishing state with the fabric")
		c.open = true
		c.SetState(Ready)

		// Reset retry delay after successful connection.
		c.retryDelay = initialRetryDelay

		go c.replayRegistrations()
		go c.replaySubscriptions()

	case *goodbye:
		c.Connection.Close("Fabric said goodbye. Closing connection")

	default:
		c.findListener(msg)
	}
}

// Find the appropriate listener and pass it the message
func (c *app) findListener(msg message) {
	id, ok := requestID(msg)

	// Catch control messages here and replace getMessageTimeout

	if ok {
		c.listenersLock.Lock()
		if l, found := c.listeners[id]; found {
			l <- msg
			c.listenersLock.Unlock()
		} else {
			c.listenersLock.Unlock()
			Error("No listener for message %v", msg)
		}
	} else {
		panic("Bad handler picking up requestID!")
	}
}

// All incoming messages end up here one way or another
func (c *app) ReceiveMessage(msg message) {
	c.in <- msg
}

// Theres a method on the serializer that does this exact thing. Is this specific to JS?
func (c *app) ReceiveBytes(byt []byte) {
	var dat []interface{}

	if err := json.Unmarshal(byt, &dat); err != nil {
		Info("Unable to unmarshal json! Message: %v", string(byt))
	} else {
		if m, err := c.serializer.deserializeString(dat); err == nil {
			c.ReceiveMessage(m)
		} else {
			Info("Unable to unmarshal json string! Message: %v", m)
		}
	}
}

// Send a message and blocks until the expected type of message is returned
// String check on the type... pretty bad. Come back to this and figure out how to reflect the interface
func (c *app) requestListenType(outgoing message, expecting string) (message, error) {
	c.Queue(outgoing)

	wait := make(chan message, 1)
	id, _ := requestID(outgoing)

	c.listenersLock.Lock()
	c.listeners[id] = wait
	c.listenersLock.Unlock()

	defer func() {
		c.listenersLock.Lock()
		delete(c.listeners, id)
		c.listenersLock.Unlock()
	}()

	select {
	case msg := <-wait:
		if e, ok := msg.(*errorMessage); ok {
			// If only one argument is passed through, format it nicely for
			// transmission to the crust
			//
			// TODO: Pass along multiple pieces of information (the error type
			// and the error message, at least).  However, the whole chain of
			// functions relying on requestListType expect a simple 'error'
			// object.
			if len(e.Arguments) >= 1 {
				return nil, fmt.Errorf("%v: %v", e.Error, e.Arguments[0])
			} else {
				return nil, fmt.Errorf("%v", e.Error)
			}
		} else if reflect.TypeOf(msg).String() != expecting {
			return nil, fmt.Errorf(formatUnexpectedMessage(msg, expecting))
		} else {
			return msg, nil
		}
	case <-time.After(MessageTimeout):
		return nil, fmt.Errorf("Timeout while waiting for message")
	}
}

func (c *app) replayRegistrations() error {
	for _, dom := range c.domains {
		for oldregid, boundep := range dom.registrations {
			register := &register{
				Request: boundep.callback,
				Options: make(map[string]interface{}),
				Name:    boundep.endpoint,
			}

			if msg, err := c.requestListenType(register, "*core.registered"); err != nil {
				return err
			} else {
				reg := msg.(*registered)

				Info("Registered: %s %v", boundep.endpoint, boundep.expectedTypes)

				dom.regLock.Lock()
				delete(dom.registrations, oldregid)
				dom.registrations[reg.Registration] = boundep
				dom.regLock.Unlock()
			}
		}
	}

	return nil
}

func (c *app) replaySubscriptions() error {
	for _, dom := range c.domains {
		for oldsubid, boundep := range dom.subscriptions {
			subscribe := &subscribe{
				Request: boundep.callback,
				Options: make(map[string]interface{}),
				Name:    boundep.endpoint,
			}

			if msg, err := c.requestListenType(subscribe, "*core.subscribed"); err != nil {
				return err
			} else {
				sub := msg.(*subscribed)

				Info("Subscribed: %s %v", boundep.endpoint, boundep.expectedTypes)

				dom.subLock.Lock()
				delete(dom.subscriptions, oldsubid)
				dom.subscriptions[sub.Subscription] = boundep
				dom.subLock.Unlock()
			}
		}
	}

	return nil
}

// Send messages that were queued with the Queue method.
//
// This method is aware of the state of the underlying websocket connection, so
// it holds messages until sending is possible.
func (app *app) serviceOutgoingQueue() {
	for {
		msg, open := <-app.out
		if !open {
			Debug("Send loop closed")
			break
		} else {
			// Fast path: send the message and move on.
			err := app.Send(msg)
			for err != nil {
				Debug("Error sending message: %e", err)

				// Slow path: send failed, which probably means we are not
				// connected.  Sit and wait for the state of the underlying
				// connection to change.
				app.stateChange.L.Lock()
				for app.state != Ready {
					app.stateChange.Wait()
				}
				app.stateChange.L.Unlock()

				err = app.Send(msg)
			}
		}
	}
}

// Blocks on a message from the connection. Don't use this while the run loop is active,
// since it will compete for messages with the run loop. Bad things will happen.
// This is largely an orphan, and should be replaced.
func (c *app) getMessageTimeout() (message, error) {
	select {
	case msg, open := <-c.in:
		if !open {
			return nil, fmt.Errorf("receive channel closed")
		}

		return msg, nil
	case <-time.After(MessageTimeout):
		return nil, fmt.Errorf("timeout waiting for message")
	}
}

func (c *app) SetState(state int) {
	c.stateMutex.Lock()
	if state == Connected {
		c.open = true
	}
	c.state = state
	c.stateChange.Broadcast()
	c.stateMutex.Unlock()
}

func (c *app) ShouldReconnect() bool {
	return !c.leaving
}

func (c *app) NextRetryDelay() time.Duration {
	delay := c.retryDelay

	c.retryDelay *= 2
	if c.retryDelay < minRetryDelay {
		c.retryDelay = minRetryDelay
	} else if c.retryDelay > maxRetryDelay {
		c.retryDelay = maxRetryDelay
	}

	return delay
}

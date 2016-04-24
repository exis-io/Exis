package core

import (
	"encoding/json"
	"fmt"
	"os"
	"reflect"
	"sync"
	"time"
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

	Join() error
	SendHello() error
	SetConnection(Connection)

	SetToken(string)
	GetToken() string
	LoadKey(string) error

	Login(Domain, ...string) (Domain, error)
	RegisterAccount(Domain, string, string, string, string) (bool, error)

	// Updated for new auth api
	BetterLogin([]interface{}) (string, error)
	BetterRegister(string, string, string, string) (string, error)

	SetState(int)
	ShouldReconnect() bool
	NextRetryDelay() time.Duration

	NewDomain(string, uint64, uint64) Domain
}

type app struct {
	domains []*domain
	Connection
	serializer

	in  chan message
	out chan message
	up  chan Callback

	// Set to true if we are leaving.
	// It tells the lower layer not to try to reconnect.
	leaving bool
	open    bool

	state       int
	stateMutex  sync.Mutex
	stateChange *sync.Cond

	listeners     map[uint64]chan message
	listenersLock sync.Mutex

	appDomain string
	agent     string
	authid    string
	token     string
	key       string

	retryDelay time.Duration
}

func NewApp(name string) *app {
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
		appDomain:  name,
		retryDelay: initialRetryDelay,
	}

	a.stateChange = sync.NewCond(&a.stateMutex)

	go a.serviceOutgoingQueue()

	a.authid = os.Getenv("EXIS_AUTHID")
	a.token = os.Getenv("EXIS_TOKEN")
	a.key = os.Getenv("EXIS_KEY")

	return a
}

// This method is specific for javascript since the connection is injected there
// Call this before calling Join with an opened connection
func (a *app) SetConnection(conn Connection) {
	a.Connection = conn
	conn.SetApp(a)
}

func (a *app) Join() error {
	if a.state != Disconnected {
		return fmt.Errorf("Trying to connect, expecting connection state to be Disconnected, but is %d", a.state)
	}

	// Make sure the connection is opened
	if a.Connection == nil {
		if DefaultConnectionFactory == nil {
			return fmt.Errorf("App does not have a connection set. Call SetConnection(Connection) or set DefaultConnectionFactory")
		} else {
			if conn, err := DefaultConnectionFactory.Open(Fabric); err != nil {
				return err
			} else {
				a.Connection = conn
				conn.SetApp(a)
			}
		}
	} else {
		if !a.Connection.IsOpen() {
			return fmt.Errorf("App does not have an opened connection. Was SetConnection(Connection) called with an opened connection?")
		}
	}

	// Merge this functionality with the state enum
	a.open = true

	err := a.SendHello()
	if err != nil {
		a.Close("Could not send a hello message")
		return err
	}

	receivedWelcome := false
	for !receivedWelcome {
		msg, err := a.getMessageTimeout()
		if err != nil {
			a.Close(err.Error())
			return err
		}

		switch msg := msg.(type) {
		case *welcome:
			receivedWelcome = true
		case *challenge:
			a.handleChallenge(msg)
		default:
			a.Send(&abort{Details: map[string]interface{}{}, Reason: "Error- unexpected_message_type"})
			a.Close("Error- unexpected_message_type")
			return fmt.Errorf(formatUnexpectedMessage(msg, wELCOME.String()))
		}
	}

	a.SetState(Ready)
	go a.receiveLoop()

	// Go through each domain and trigger their onJoin methods
	for _, x := range a.domains {
		x.Join()
	}

	Info("Fabric connection established")
	return nil
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

    Info("Something with serialization?")
	if b, err := c.serializer.serialize(m); err != nil {
        Info("Bad cereal")
		return err
	} else {
        Info("Good cereal")
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
		return
	} else {
		Info("Closing internally: ", reason)
	}

	if err := c.Send(&goodbye{Details: map[string]interface{}{}, Reason: ErrCloseSession}); err != nil {
		Warn("Error sending goodbye: %v", err)
	}

	c.open = false
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
			if binding, ok := x.subscriptions.Get(msg.Subscription); ok {
				go x.handlePublish(msg, binding)
				return
			}
		}

		Warn("No handler registered for subscription:", msg.Subscription)

	case *invocation:
		for _, x := range c.domains {
			if binding, ok := x.registrations.Get(msg.Registration); ok {
				go x.handleInvocation(msg, binding)
				return
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
		// If this is a progress call call the handler, do not alert the listener
		// Listener is only updated once the call completes
		if p, ok := msg.Details["progress"]; ok {
			x := p.(bool)
			if x {
				for _, x := range c.domains {
					if binding, ok := x.handlers.Get(msg.Request); ok {
						go x.handleResult(msg, binding)
						return
					}
				}
			}
		} else {
			c.findListener(msg)
		}

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
		for t := range dom.registrations.Iter() {
			oldregid := t.Key
			boundep := t.Val

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

				dom.registrations.RemoveKey(oldregid)
				dom.registrations.Set(reg.Registration, boundep)
			}
		}
	}

	return nil
}

func (c *app) replaySubscriptions() error {
	for _, dom := range c.domains {
		for t := range dom.subscriptions.Iter() {
			oldsubid := t.Key
			boundep := t.Val

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

				dom.subscriptions.RemoveKey(oldsubid)
				dom.subscriptions.Set(sub.Subscription, boundep)
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

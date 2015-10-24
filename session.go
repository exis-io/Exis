package riffle

import (
    "fmt"
)

// Connect to the node with the given URL
func Connect(url string, domain string) (*Client, error) {
    if client, err := NewWebsocketClient(JSON, url); err != nil {
        return nil, err
    } else {
        // "Join a realm", which means try to authenticate using the hackied old system
        client.JoinRealm("xs.testerer", nil)
        return client, nil
    }
}

/////////////////////////////////////////////
// Handler methods
/////////////////////////////////////////////

// EventHandler handles a publish event.
type EventHandler func(args []interface{}, kwargs map[string]interface{})

// Subscribe registers the EventHandler to be called for every message in the provided topic.
func (c *Client) Subscribe(topic string, fn EventHandler) error {
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
        c.events[subscribed.Subscription] = &eventDesc{topic, fn}
    }
    return nil
}

// Unsubscribe removes the registered EventHandler from the topic.
func (c *Client) Unsubscribe(topic string) error {
    var (
        subscriptionID uint
        found          bool
    )
    for id, desc := range c.events {
        if desc.topic == topic {
            subscriptionID = id
            found = true
        }
    }
    if !found {
        return fmt.Errorf("Event %s is not registered with this client.", topic)
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

// MethodHandler is an RPC endpoint.
type MethodHandler func(
    args []interface{}, kwargs map[string]interface{}, details map[string]interface{},
) (result *CallResult)

// Register registers a MethodHandler procedure with the Node.
func (c *Client) Register(procedure string, fn MethodHandler, options map[string]interface{}) error {
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
        c.procedures[registered.Registration] = &procedureDesc{procedure, fn}
    }
    return nil
}

// Unregister removes a procedure with the Node
func (c *Client) Unregister(procedure string) error {
    var (
        procedureID uint
        found       bool
    )

    for id, p := range c.procedures {
        if p.name == procedure {
            procedureID = id
            found = true
        }
    }

    if !found {
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
func (c *Client) Publish(topic string, args []interface{}, kwargs map[string]interface{}) error {
    return c.Send(&Publish{
        Request:     NewID(),
        Options:     make(map[string]interface{}),
        Domain:      topic,
        Arguments:   args,
        ArgumentsKw: kwargs,
    })
}

// Call calls a procedure given a URI.
func (c *Client) Call(procedure string, args []interface{}, kwargs map[string]interface{}) (*Result, error) {
    id := NewID()
    c.registerListener(id)

    call := &Call{
        Request:     id,
        Domain:      procedure,
        Options:     make(map[string]interface{}),
        Arguments:   args,
        ArgumentsKw: kwargs,
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
        return result, nil
    }
}

/////////////////////////////////////////////
// Misc
/////////////////////////////////////////////

// LeaveRealm leaves the current realm without closing the connection to the server.
func (c *Client) LeaveRealm() error {
    if err := c.Send(goodbyeClient); err != nil {
        return fmt.Errorf("error leaving realm: %v", err)
    }
    return nil
}

// JoinRealm joins a WAMP realm, but does not handle challenge/response authentication.
func (c *Client) JoinRealm(realm string, details map[string]interface{}) (map[string]interface{}, error) {
    if details == nil {
        details = map[string]interface{}{}
    }

    details["roles"] = map[string]map[string]interface{}{
        "publisher":  make(map[string]interface{}),
        "subscriber": make(map[string]interface{}),
        "callee":     make(map[string]interface{}),
        "caller":     make(map[string]interface{}),
    }

    if c.Auth != nil && len(c.Auth) > 0 {
        return c.joinRealmCRA(realm, details)
    }

    if err := c.Send(&Hello{Realm: realm, Details: details}); err != nil {
        c.Peer.Close()
        return nil, err
    }

    if msg, err := GetMessageTimeout(c.Peer, c.ReceiveTimeout); err != nil {
        c.Peer.Close()
        return nil, err
    } else if welcome, ok := msg.(*Welcome); !ok {
        c.Send(abortUnexpectedMsg)
        c.Peer.Close()
        return nil, fmt.Errorf(formatUnexpectedMessage(msg, WELCOME))
    } else {
        go c.Receive()
        return welcome.Details, nil
    }
}

// joinRealmCRA joins a WAMP realm and handles challenge/response authentication.
func (c *Client) joinRealmCRA(realm string, details map[string]interface{}) (map[string]interface{}, error) {
    authmethods := []interface{}{}
    for m := range c.Auth {
        authmethods = append(authmethods, m)
    }
    details["authmethods"] = authmethods
    if err := c.Send(&Hello{Realm: realm, Details: details}); err != nil {
        c.Peer.Close()
        return nil, err
    }
    if msg, err := GetMessageTimeout(c.Peer, c.ReceiveTimeout); err != nil {
        c.Peer.Close()
        return nil, err
    } else if challenge, ok := msg.(*Challenge); !ok {
        c.Send(abortUnexpectedMsg)
        c.Peer.Close()
        return nil, fmt.Errorf(formatUnexpectedMessage(msg, CHALLENGE))
    } else if authFunc, ok := c.Auth[challenge.AuthMethod]; !ok {
        c.Send(abortNoAuthHandler)
        c.Peer.Close()
        return nil, fmt.Errorf("no auth handler for method: %s", challenge.AuthMethod)
    } else if signature, authDetails, err := authFunc(details, challenge.Extra); err != nil {
        c.Send(abortAuthFailure)
        c.Peer.Close()
        return nil, err
    } else if err := c.Send(&Authenticate{Signature: signature, Extra: authDetails}); err != nil {
        c.Peer.Close()
        return nil, err
    }
    if msg, err := GetMessageTimeout(c.Peer, c.ReceiveTimeout); err != nil {
        c.Peer.Close()
        return nil, err
    } else if welcome, ok := msg.(*Welcome); !ok {
        c.Send(abortUnexpectedMsg)
        c.Peer.Close()
        return nil, fmt.Errorf(formatUnexpectedMessage(msg, WELCOME))
    } else {
        go c.Receive()
        return welcome.Details, nil
    }
}

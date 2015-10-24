package riffle

import (
    "fmt"
    "sync"
    "time"

    "github.com/gorilla/websocket"
)

type Sender interface {
    Send(Message) error
}

type Client struct {
    Connection
    ReceiveTimeout time.Duration
    Auth           map[string]AuthFunc
    ReceiveDone    chan bool
    listeners      map[uint]chan Message
    events         map[uint]*eventDesc
    procedures     map[uint]*procedureDesc
    requestCount   uint
    pdid           string
}

type procedureDesc struct {
    name    string
    handler MethodHandler
}

type eventDesc struct {
    topic   string
    handler EventHandler
}

type Connection interface {
    Sender

    // Closes the peer connection and any channel returned from Receive().
    // Multiple calls to Close() will have no effect.
    Close() error

    // Receive returns a channel of messages coming from the peer.
    Receive() <-chan Message
}

type AuthFunc func(map[string]interface{}, map[string]interface{}) (string, map[string]interface{}, error)

type websocketConnection struct {
    conn        *websocket.Conn
    connLock    sync.Mutex
    serializer  Serializer
    messages    chan Message
    payloadType int
    closed      bool
}

// Creates a new websocket client.
func NewWebsocketClient(serialization Serialization, url string) (*Client, error) {
    p, err := NewWebsocketConnection(serialization, url, "")
    if err != nil {
        return nil, err
    }
    return &Client{
        Connection:     p,
        ReceiveTimeout: 10 * time.Second,
        listeners:      make(map[uint]chan Message),
        events:         make(map[uint]*eventDesc),
        procedures:     make(map[uint]*procedureDesc),
        requestCount:   0,
    }, nil
}

func formatUnexpectedMessage(msg Message, expected MessageType) string {
    s := fmt.Sprintf("received unexpected %s message while waiting for %s", msg.MessageType(), expected)
    switch m := msg.(type) {
    case *Abort:
        s += ": " + string(m.Reason)
        s += formatUnknownMap(m.Details)
        return s
    case *Goodbye:
        s += ": " + string(m.Reason)
        s += formatUnknownMap(m.Details)
        return s
    }
    return s
}

func formatUnknownMap(m map[string]interface{}) string {
    s := ""
    for k, v := range m {
        // TODO: reflection to recursively check map
        s += fmt.Sprintf(" %s=%v", k, v)
    }
    return s
}

// Close closes the connection to the server.
func (c *Client) Close() error {
    if err := c.LeaveRealm(); err != nil {
        return err
    }

    if err := c.Connection.Close(); err != nil {
        return fmt.Errorf("error closing client connection: %v", err)
    }
    return nil
}

// func (c *Client) nextID() uint {
//  c.requestCount++
//  return uint(c.requestCount)
// }

// Receive handles messages from the server until this client disconnects.
//
// This function blocks and is most commonly run in a goroutine.
func (c *Client) Receive() {
    for msg := range c.Connection.Receive() {

        switch msg := msg.(type) {

        case *Event:
            if event, ok := c.events[msg.Subscription]; ok {
                go event.handler(msg.Arguments, msg.ArgumentsKw)
            } else {
                //log.Println("no handler registered for subscription:", msg.Subscription)
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
            //log.Println("client received Goodbye message")
            break

        default:
            //log.Println("unhandled message:", msg.MessageType(), msg)
        }
    }
    //log.Println("client closed")

    if c.ReceiveDone != nil {
        c.ReceiveDone <- true
    }
}

func (c *Client) notifyListener(msg Message, requestId uint) {
    // pass in the request uint so we don't have to do any type assertion
    if l, ok := c.listeners[requestId]; ok {
        l <- msg
    } else {
        //log.Println("no listener for message", msg.MessageType(), requestId)
    }
}

func (c *Client) handleInvocation(msg *Invocation) {
    if proc, ok := c.procedures[msg.Registration]; ok {
        go func() {
            result := proc.handler(msg.Arguments, msg.ArgumentsKw, msg.Details)

            var tosend Message
            tosend = &Yield{
                Request:     msg.Request,
                Options:     make(map[string]interface{}),
                Arguments:   result.Args,
                ArgumentsKw: result.Kwargs,
            }

            if result.Err != "" {
                tosend = &Error{
                    Type:        INVOCATION,
                    Request:     msg.Request,
                    Details:     make(map[string]interface{}),
                    Arguments:   result.Args,
                    ArgumentsKw: result.Kwargs,
                    Error:       result.Err,
                }
            }

            if err := c.Send(tosend); err != nil {
                //log.Println("error sending message:", err)
            }
        }()
    } else {
        //log.Println("no handler registered for registration:", msg.Registration)
        if err := c.Send(&Error{
            Type:    INVOCATION,
            Request: msg.Request,
            Details: make(map[string]interface{}),
            Error:   fmt.Sprintf("no handler for registration: %v", msg.Registration),
        }); err != nil {
            //log.Println("error sending message:", err)
        }
    }
}

func (c *Client) registerListener(id uint) {
    //log.Println("register listener:", id)
    wait := make(chan Message, 1)
    c.listeners[id] = wait
}

func (c *Client) waitOnListener(id uint) (msg Message, err error) {
    //log.Println("wait on listener:", id)
    if wait, ok := c.listeners[id]; !ok {
        return nil, fmt.Errorf("unknown listener uint: %v", id)
    } else {
        select {
        case msg = <-wait:
            return
        case <-time.After(c.ReceiveTimeout):
            err = fmt.Errorf("timeout while waiting for message")
            return
        }
    }
}

// Convenience function to get a single message from a peer
func GetMessageTimeout(p Connection, t time.Duration) (Message, error) {
    select {
    case msg, open := <-p.Receive():
        if !open {
            return nil, fmt.Errorf("receive channel closed")
        }
        return msg, nil
    case <-time.After(t):
        return nil, fmt.Errorf("timeout waiting for message")
    }
}

// NewWebsocketConnection connects to the websocket server at the specified url.
func NewWebsocketConnection(serialization Serialization, url, origin string) (Connection, error) {
    switch serialization {
    case JSON:
        return newWebsocketConnection(url, "wamp.2.json", origin,
            new(JSONSerializer), websocket.TextMessage,
        )
    case MSGPACK:
        return newWebsocketConnection(url, "wamp.2.msgpack", origin,
            new(MessagePackSerializer), websocket.BinaryMessage,
        )
    default:
        return nil, fmt.Errorf("Unsupported serialization: %v", serialization)
    }
}

func newWebsocketConnection(url, protocol, origin string, serializer Serializer, payloadType int) (Connection, error) {
    dialer := websocket.Dialer{
        Subprotocols: []string{protocol},
    }

    conn, _, err := dialer.Dial(url, nil)
    if err != nil {
        return nil, err
    }

    ep := &websocketConnection{
        conn:        conn,
        messages:    make(chan Message, 10),
        serializer:  serializer,
        payloadType: payloadType,
    }

    go ep.run()

    return ep, nil
}

// TODO: make this just add the message to a channel so we don't block
func (ep *websocketConnection) Send(msg Message) error {
    b, err := ep.serializer.Serialize(msg)

    if err != nil {
        return err
    }

    ep.connLock.Lock()
    err = ep.conn.WriteMessage(ep.payloadType, b)
    ep.connLock.Unlock()

    return err
}

func (ep *websocketConnection) Receive() <-chan Message {
    return ep.messages
}

func (ep *websocketConnection) Close() error {
    closeMsg := websocket.FormatCloseMessage(websocket.CloseNormalClosure, "goodbye")
    err := ep.conn.WriteControl(websocket.CloseMessage, closeMsg, time.Now().Add(5*time.Second))

    if err != nil {
        //log.Println("error sending close message:", err)
    }

    ep.closed = true
    return ep.conn.Close()
}

func (ep *websocketConnection) run() {
    for {
        // TODO: use conn.NextMessage() and stream
        // TODO: do something different based on binary/text frames
        if msgType, b, err := ep.conn.ReadMessage(); err != nil {
            if ep.closed {
                //log.Println("peer connection closed")
            } else {
                //log.Println("error reading from peer:", err)
                ep.conn.Close()
            }
            close(ep.messages)
            break
        } else if msgType == websocket.CloseMessage {
            ep.conn.Close()
            close(ep.messages)
            break
        } else {
            msg, err := ep.serializer.Deserialize(b)
            if err != nil {
                //log.Println("error deserializing peer message:", err)
                // TODO: handle error
            } else {
                ep.messages <- msg
            }
        }
    }
}

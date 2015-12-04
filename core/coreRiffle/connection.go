package goriffle

import (
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

type websocketConnection struct {
	conn        *websocket.Conn
	connLock    sync.Mutex
	serializer  serializer
	messages    chan message
	payloadType int
	closed      bool
}

type sender interface {
	Send(message) error
}

type connection interface {
	sender

	// Closes the peer connection and any channel returned from Receive().
	// Multiple calls to Close() will have no effect.
	Close() error

	// Receive returns a channel of messages coming from the peer.
	Receive() <-chan message
}

// TODO: make this just add the message to a channel so we don't block
func (ep *websocketConnection) Send(msg message) error {

	b, err := ep.serializer.serialize(msg)

	if err != nil {
		return err
	}

	ep.connLock.Lock()
	err = ep.conn.WriteMessage(ep.payloadType, b)
	ep.connLock.Unlock()

	return err
}

func (ep *websocketConnection) Receive() <-chan message {
	return ep.messages
}

func (ep *websocketConnection) Close() error {
	closeMsg := websocket.FormatCloseMessage(websocket.CloseNormalClosure, "goodbye")
	err := ep.conn.WriteControl(websocket.CloseMessage, closeMsg, time.Now().Add(5*time.Second))

	if err != nil {
		log.Println("error sending close message:", err)
	}

	ep.closed = true
	return ep.conn.Close()

	return nil
}

func (ep *websocketConnection) run() {
	for {
		if msgType, b, err := ep.conn.ReadMessage(); err != nil {
			if ep.closed {
				log.Println("peer connection closed")
			} else {
				log.Println("error reading from peer:", err)
				ep.conn.Close()
			}
			close(ep.messages)
			break
		} else if msgType == websocket.CloseMessage {
			fmt.Println("Close message recieved")
			ep.conn.Close()
			close(ep.messages)
			break
		} else {
			msg, err := ep.serializer.deserialize(b)
			if err != nil {
				log.Println("error deserializing peer message:", err)
				log.Println(b)
				// TODO: handle error
			} else {
				fmt.Println("Message received!")
				ep.messages <- msg
			}
		}
	}
}

func (c *Domain) registerListener(id uint) {
	//log.Println("register listener:", id)
	wait := make(chan message, 1)
	c.listeners[id] = wait
}

func (c *Domain) waitOnListener(id uint) (message, error) {
	if wait, ok := c.listeners[id]; !ok {
		return nil, fmt.Errorf("unknown listener uint: %v", id)
	} else {
		select {
		case msg := <-wait:
			return msg, nil
		case <-time.After(timeout):
			return nil, fmt.Errorf("timeout while waiting for message")
		}
	}
}

func (c *Domain) notifyListener(msg message, requestId uint) {
	// pass in the request uint so we don't have to do any type assertion
	if l, ok := c.listeners[requestId]; ok {
		l <- msg
	} else {
		log.Println("no listener for message", msg.messageType(), requestId)
	}
}

// Convenience function to get a single message from a peer
func getMessageTimeout(p connection, t time.Duration) (message, error) {
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

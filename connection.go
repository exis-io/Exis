package goRiffle

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

func Open() {
	dialer := websocket.Dialer{Subprotocols: []string{"wamp.2.json"}}
	conn, _, err := dialer.Dial(url, nil)

	if err != nil {
		return nil, err
	}

	connection := &websocketConnection{
		conn:        conn,
		messages:    make(chan message, 10),
		serializer:  new(jSONSerializer),
		payloadType: websocket.TextMessage,
	}

	if err != nil {
		return nil, err
	}

	go connection.run()
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

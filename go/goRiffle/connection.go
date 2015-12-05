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
	messages    chan message
	payloadType int
	closed      bool
}

func Open(url string) (*websocketConnection, error) {
	dialer := websocket.Dialer{Subprotocols: []string{"wamp.2.json"}}
	conn, _, err := dialer.Dial(url, nil)

	if err != nil {
		return nil, err
	}

	connection := &websocketConnection{
		conn:        conn,
		messages:    make(chan message, 10),
		payloadType: websocket.TextMessage,
	}

	go connection.run()

	return connection, nil
}

func (ep *websocketConnection) Send(data []byte) error {

	ep.connLock.Lock()
	err := ep.conn.WriteMessage(ep.payloadType, data)
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
		// the blank assignment is 'b'
		if msgType, _, err := ep.conn.ReadMessage(); err != nil {
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
			// msg, err := ep.serializer.deserialize(b)
			// if err != nil {
			// 	log.Println("error deserializing peer message:", err)
			// 	log.Println(b)
			// 	// TODO: handle error
			// } else {
			// 	fmt.Println("Message received!")
			// 	ep.messages <- msg
			// }
		}
	}
}

func (c websocketConnection) BlockMessage() (message, error) {
	return getMessageTimeout(*c, t)
}

func getMessageTimeout(p websocketConnection, t time.Duration) (message, error) {
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

// Receive handles messages from the server until this client disconnects.
// This function blocks and is most commonly run in a goroutine.
// func (c *domain) Receive() {
// 	for msg := range c.Connection.Receive() {
// 		c.Handle(msg)
// 	}
// }

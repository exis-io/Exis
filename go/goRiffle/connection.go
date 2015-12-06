package goRiffle

import (
	"fmt"
	"log"
	"time"

	"github.com/exis-io/coreRiffle"
	"github.com/gorilla/websocket"
)

type websocketConnection struct {
	conn *websocket.Conn
	coreRiffle.Honcho
	payloadType int
	closed      bool
}

func Open(url string) (*websocketConnection, error) {
	dialer := websocket.Dialer{Subprotocols: []string{"wamp.2.json"}}

	if conn, _, err := dialer.Dial(url, nil); err != nil {
		return nil, err
	} else {
		connection := &websocketConnection{
			conn:        conn,
			payloadType: websocket.TextMessage,
		}

		go connection.run()
		return connection, nil
	}
}

func (ep *websocketConnection) Send(data []byte) {
	if err := ep.conn.WriteMessage(ep.payloadType, data); err != nil {
		panic("No one is dealing with my errors! Cant write to socket")
	}
}

// Who the hell do we call close first on? Honcho or connection?
// Either way one or the other may have to check on the other, which is no good
func (ep *websocketConnection) Close() error {
	closeMsg := websocket.FormatCloseMessage(websocket.CloseNormalClosure, "goodbye")
	err := ep.conn.WriteControl(websocket.CloseMessage, closeMsg, time.Now().Add(5*time.Second))

	if err != nil {
		log.Println("error sending close message:", err)
	}

	ep.closed = true
	return ep.conn.Close()
}

func (ep *websocketConnection) run() {
	// Theres some missing logic here when it comes to dealing with closes, including whats
	// actually returned from those closes

	for {
		// the blank assignment is 'b'
		if msgType, bytes, err := ep.conn.ReadMessage(); err != nil {
			if ep.closed {
				log.Println("peer connection closed")
			} else {
				log.Println("error reading from peer:", err)
				ep.conn.Close()
			}

			// ep.Honcho.Close()
			break
		} else if msgType == websocket.CloseMessage {
			fmt.Println("Close message recieved")
			ep.conn.Close()

			// ep.Honcho.Close()
			break
		} else {
			ep.Honcho.ReceiveBytes(bytes)
		}
	}
}

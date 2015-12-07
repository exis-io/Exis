package goRiffle

import (
	"log"
	"time"

	"github.com/exis-io/coreRiffle"
	"github.com/gorilla/websocket"
)

type websocketConnection struct {
	conn *websocket.Conn
	// connLock sync.Mutex
	coreRiffle.App
	payloadType int
	closed      bool
}

func Open(url string) (*websocketConnection, error) {
	coreRiffle.Debug("Opening ws connection to %s", url)
	dialer := websocket.Dialer{Subprotocols: []string{"wamp.2.json"}}

	if conn, _, err := dialer.Dial(url, nil); err != nil {
		coreRiffle.Debug("Cant dial connection: %e", err)
		return nil, err
	} else {
		coreRiffle.Debug("Connection dialed")

		connection := &websocketConnection{
			conn:        conn,
			payloadType: websocket.TextMessage,
		}

		go connection.run()
		return connection, nil
	}
}

func (ep *websocketConnection) Send(data []byte) {
	// coreRiffle.Debug("Writing data")
	// Does the lock block? The locks should be faster than working off the channel,
	// but the comments in the other code imply that the lock blocks on the send?

	if err := ep.conn.WriteMessage(ep.payloadType, data); err != nil {
		panic("No one is dealing with my errors! Cant write to socket")
	}
}

// Who the hell do we call close first on? App or connection?
// Either way one or the other may have to check on the other, which is no good
func (ep *websocketConnection) Close(reason string) error {
	coreRiffle.Info("Closing connection with reason: %s", reason)
	closeMsg := websocket.FormatCloseMessage(websocket.CloseNormalClosure, "goodbye")
	err := ep.conn.WriteControl(websocket.CloseMessage, closeMsg, time.Now().Add(5*time.Second))

	if err != nil {
		log.Println("error sending close message:", err)
	}

	// Close the channel!

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
				coreRiffle.Info("peer connection closed")
			} else {
				coreRiffle.Info("error reading from peer:", err)
				ep.conn.Close()
			}

			// ep.App.Close()
			break
		} else if msgType == websocket.CloseMessage {
			coreRiffle.Info("Close message recieved")
			ep.conn.Close()

			// ep.App.Close()
			break
		} else {
			// coreRiffle.Debug("Socket received data")
			ep.App.ReceiveBytes(bytes)
		}
	}
}

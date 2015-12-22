package goRiffle

import (
	"log"
	"sync"
	"time"

	"github.com/exis-io/core"
	"github.com/gorilla/websocket"
)

type WebsocketConnection struct {
	conn        *websocket.Conn
	lock        *sync.Mutex
	app         core.App
	payloadType int
	closed      bool
}

func Open(url string) (*WebsocketConnection, error) {
	core.Debug("Opening ws connection to %s", url)
	dialer := websocket.Dialer{Subprotocols: []string{"wamp.2.json"}}

	if conn, _, err := dialer.Dial(url, nil); err != nil {
		core.Debug("Cant dial connection: %e", err)
		return nil, err
	} else {
		connection := &WebsocketConnection{
			conn:        conn,
			lock:        &sync.Mutex{},
			payloadType: websocket.TextMessage,
		}

		go connection.run()
		return connection, nil
	}
}

func (ep *WebsocketConnection) Send(data []byte) {
	// core.Debug("Writing data")
	// Does the lock block? The locks should be faster than working off the channel,
	// but the comments in the other code imply that the lock blocks on the send?

	ep.lock.Lock()
	if err := ep.conn.WriteMessage(ep.payloadType, data); err != nil {
		core.Warn("No one is dealing with my errors! Cant write to socket. Eror: %s", err)
		panic("Unrecoverable error")
	}
	ep.lock.Unlock()
}

func (ep *WebsocketConnection) SetApp(app core.App) {
	ep.app = app
}

// Who the hell do we call close first on? App or connection?
// Either way one or the other may have to check on the other, which is no good
func (ep *WebsocketConnection) Close(reason string) error {
	core.Info("Closing connection with reason: %s", reason)

	closeMsg := websocket.FormatCloseMessage(websocket.CloseNormalClosure, "goodbye")
	err := ep.conn.WriteControl(websocket.CloseMessage, closeMsg, time.Now().Add(5*time.Second))

	if err != nil {
		log.Println("error sending close message:", err)
	}

	ep.lock = nil
	ep.closed = true

	return ep.conn.Close()
}

func (ep *WebsocketConnection) run() {
	// Theres some missing logic here when it comes to dealing with closes, including whats
	// actually returned from those closes

	for {
		if msgType, bytes, err := ep.conn.ReadMessage(); err != nil {
			if ep.closed {
				core.Info("peer connection closed")
			} else {
				core.Info("error reading from peer:", err)
				ep.conn.Close()
			}

			// ep.App.Close()
			break
		} else if msgType == websocket.CloseMessage {
			core.Info("Close message recieved")
			ep.conn.Close()

			// ep.App.Close()
			break
		} else {
			ep.app.ReceiveBytes(bytes)
		}
	}
}

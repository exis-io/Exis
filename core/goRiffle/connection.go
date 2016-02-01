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
	url         string
}

const (
	minRetryDelay = 1  * time.Second
	maxRetryDelay = 30 * time.Second
)

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
			url:         url,
		}

		go connection.run()
		return connection, nil
	}
}

func (ep *WebsocketConnection) Send(data []byte) error {
	// core.Debug("Writing data")
	// Does the lock block? The locks should be faster than working off the channel,
	// but the comments in the other code imply that the lock blocks on the send?
	// Yes, locks can block.  Not sure about faster.

	ep.lock.Lock()
	defer ep.lock.Unlock()

	err := ep.conn.WriteMessage(ep.payloadType, data)
	if err != nil {
		core.Warn("Error writing to socket: %s", err)
	}
	return err
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

	ep.closed = true

	return ep.conn.Close()
}

func (ep *WebsocketConnection) Reconnect() error {
	delay := minRetryDelay

	for {
		core.Debug("Opening connection to %s", ep.url)
		dialer := websocket.Dialer{Subprotocols: []string{"wamp.2.json"}}

		if conn, _, err := dialer.Dial(ep.url, nil); err != nil {
			core.Debug("Connection failed: %e", err)
		} else {
			// Set pointer to new websocket connection.
			ep.lock.Lock()
			ep.conn = conn
			ep.lock.Unlock()

			if err := ep.app.SendHello(); err != nil {
				core.Debug("Sending HELLO failed: %e", err)
				ep.conn.Close()
			} else {
				return nil
			}
		}

		core.Debug("Retry in %v", delay)

		time.Sleep(delay)

		// Exponential backoff up to maxRetryDelay.
		delay *= 2
		if delay > maxRetryDelay {
			delay = maxRetryDelay
		}
	}
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

			ep.app.ConnectionClosed("Peer connection closed")
			if ep.app.ShouldReconnect() {
				ep.Reconnect()
			} else {
				break
			}
		} else if msgType == websocket.CloseMessage {
			core.Info("Close message recieved")
			ep.conn.Close()

			ep.app.ConnectionClosed("Close message received")
			if ep.app.ShouldReconnect() {
				ep.Reconnect()
			} else {
				break
			}
		} else {
			ep.app.ReceiveBytes(bytes)
		}
	}
}

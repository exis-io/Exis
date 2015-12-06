package coreRiffle

// import (
// 	"fmt"
// 	"time"
// )

// // Abstract connection, wrapping around the external connection provider

// type Connection interface {
// 	// Send a message
// 	Send(message) error

// 	// Closes the peer connection and any channel returned from Receive().
// 	// Calls with a reason for the close
// 	Close(string)

// 	// Receive returns a channel of messages coming from the peer.
// 	// NOTE: I think this should be reactive
// 	// Receive() <-chan message
// }

// type internalConnection struct {
// 	in  chan message
// 	out chan message
// }

// func (c *connection) getMessageTimeout() (message, error) {
// 	select {
// 	case msg, open := <-c.in:
// 		if !open {
// 			return nil, fmt.Errorf("receive channel closed")
// 		}

// 		return msg, nil
// 	case <-time.After(t):
// 		return nil, fmt.Errorf("timeout waiting for message")
// 	}
// }

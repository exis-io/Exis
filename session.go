package riffle

import (
	"fmt"
	"time"
)

// Auth levels
// Low means agent presented a pdid but no credentials.
// High means agent presented valid credentials.
// TODO: Remove once all agents are required to be authenticated.
const (
	AUTH_NONE = iota
	AUTH_LOW  = iota
	AUTH_HIGH = iota
)

type Session struct {
	Peer
	Id   ID
	pdid URI

	// authid is the highest domain the agent has been authenticated as,
	// so it is the one we should use for permissions checking.
	authid string

	// TODO: Remove once authentication is enabled for all agents.
	authLevel int

	kill chan URI
}

func (s Session) String() string {
	return fmt.Sprintf("%s", s.pdid)
}

// Test if session is a local (built-in) peer.
func (s *Session) isLocal() bool {
	_, ok := s.Peer.(*localPeer)
	return ok
}

// localPipe creates two linked sessions. Messages sent to one will
// appear in the Receive of the other. This is useful for implementing
// client sessions
func localPipe() (*localPeer, *localPeer) {
	aToB := make(chan Message, 10)
	bToA := make(chan Message, 10)

	a := &localPeer{
		incoming: bToA,
		outgoing: aToB,
	}
	b := &localPeer{
		incoming: aToB,
		outgoing: bToA,
	}

	return a, b
}

type localPeer struct {
	outgoing chan<- Message
	incoming <-chan Message
}

func (s *localPeer) Receive() <-chan Message {
	return s.incoming
}

func (s *localPeer) Send(msg Message) error {
	s.outgoing <- msg
	return nil
}

func (s *localPeer) Close() error {
	close(s.outgoing)
	return nil
}

////////////////////////////////////////
// Contents of old 'peer.go' file
////////////////////////////////////////

// A Sender can send a message to its peer.
//
// For clients, this sends a message to the Node, and for Nodes,
// this sends a message to the client.
type Sender interface {
	// Send a message to the peer
	Send(Message) error
}

// Peer is the interface that must be implemented by all WAMP peers.
type Peer interface {
	Sender

	// Closes the peer connection and any channel returned from Receive().
	// Multiple calls to Close() will have no effect.
	Close() error

	// Receive returns a channel of messages coming from the peer.
	Receive() <-chan Message
}

// Convenience function to get a single message from a peer
func GetMessageTimeout(p Peer, t time.Duration) (Message, error) {
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

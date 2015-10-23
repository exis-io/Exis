package riffle

import "fmt"

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

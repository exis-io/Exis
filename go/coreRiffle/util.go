package coreRiffle

import (
	"fmt"
	"math/rand"
	"time"
)

const (
	maxId   int64         = 1 << 53
	timeout time.Duration = 5 * time.Second
)

type Connection interface {
	Send(message) error

	// Closes the peer connection and any channel returned from Receive().
	// Multiple calls to Close() will have no effect.
	Close() error

	// Receive returns a channel of messages coming from the peer.
	// NOTE: I think this should be reactive
	Receive() <-chan message

	// Wait for a message for a timeout amount of time
	BlockMessage() (message, error)
}

type Persistence interface {
	Load(string) []byte

	Save(string, []byte)
}

func init() {
	rand.Seed(time.Now().UnixNano())
}

// NewID generates a random WAMP uint.
func newID() uint {
	return uint(rand.Int63n(maxId))
}

func formatUnexpectedMessage(msg message, expected messageType) string {
	s := fmt.Sprintf("received unexpected %s message while waiting for %s", msg.messageType(), expected)
	switch m := msg.(type) {
	case *abort:
		s += ": " + string(m.Reason)
		s += formatUnknownMap(m.Details)
		return s
	case *goodbye:
		s += ": " + string(m.Reason)
		s += formatUnknownMap(m.Details)
		return s
	}
	return s
}

func formatUnknownMap(m map[string]interface{}) string {
	s := ""
	for k, v := range m {
		// TODO: reflection to recursively check map
		s += fmt.Sprintf(" %s=%v", k, v)
	}
	return s
}

// type RealmExistsError string

// func (e RealmExistsError) Error() string {
//  return "realm exists: " + string(e)
// }

// type NoSuchRealmError string

// func (e NoSuchRealmError) Error() string {
//  return "no such realm: " + string(e)
// }

// type AuthenticationError string

// func (e AuthenticationError) Error() string {
//  return "authentication error: " + string(e)
// }

type InvalidURIError string

func (e InvalidURIError) Error() string {
	return "invalid URI: " + string(e)
}

const (
	// ErrInvalidUri = "wamp.error.invalid_uri"
	// ErrNoSuchdomain = "wamp.error.no_such_procedure"
	// ErrdomainAlreadyExists = "wamp.error.procedure_already_exists"
	// ErrNoSuchRegistration = "Registration"
	// ErrNoSuchSubscription = "Subscription does not exist"

	ErrInvalidArgument     = "Invalid Arguments"
	ErrSystemShutdown      = "Connection collapsed"
	ErrCloseRealm          = "Im leaving"
	ErrGoodbyeAndOut       = "Goodbye and go away"
	ErrNotAuthorized       = "Not Authorized"
	ErrAuthorizationFailed = "Unable to Authorize"
)

func bindingForEndpoint(bindings map[uint]*boundEndpoint, endpoint string) (uint, *boundEndpoint, bool) {
	for id, p := range bindings {
		if p.endpoint == endpoint {
			return id, p, true
		}
	}

	return 0, nil, false
}

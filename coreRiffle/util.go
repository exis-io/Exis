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
	// ErrNoSuchDomain = "wamp.error.no_such_procedure"
	// ErrDomainAlreadyExists = "wamp.error.procedure_already_exists"
	// ErrNoSuchRegistration = "Registration"
	// ErrNoSuchSubscription = "Subscription does not exist"

	ErrInvalidArgument     = "Invalid Arguments"
	ErrSystemShutdown      = "Connection collapsed"
	ErrCloseRealm          = "Im leaving"
	ErrGoodbyeAndOut       = "Goodbye and go away"
	ErrNotAuthorized       = "Not Authorized"
	ErrAuthorizationFailed = "Unable to Authorize"
)

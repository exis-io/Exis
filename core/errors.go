package core

const (
	// A call could not be performed because there is no registered handler
	// for the endpoint.
	ErrNoSuchRegistration = "wamp.error.no_such_registration"

	// A call failed because the given argument types or values differ from
	// what the callee expects.
	ErrInvalidArgument = "wamp.error.invalid_argument"

	// The peer wants to close the session, sent as a GOODBYE reason.
	ErrCloseSession = "wamp.error.close_session"
)

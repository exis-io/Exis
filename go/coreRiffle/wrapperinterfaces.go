package coreRiffle

// Wrapper-provided interfaces

type Connection interface {
	Send(message) error

	// Open an connection with the given URL. Wrappers can feel free to override them
	Open(string)

	// Closes the peer connection and any channel returned from Receive().
	// Multiple calls to Close() will have no effect.
	Close() error

	// Receive returns a channel of messages coming from the peer.
	// NOTE: I think this should be reactive
	Receive() <-chan message
}

// The representation of a domain from the perspective of the wrapper.
type Relay interface {

	// Called by core when something needs doing
	Invoke(uint, []interface{}, map[string]interface{})

	OnJoin()
	OnLeave()
}

type Persistence interface {
	Load(string) []byte

	Save(string, []byte)
}

// Internal interfaces

type Domaine interface {
	Subscribe(string, []interface{}) (uint, error)
	Register(string, []interface{}) (uint, error)

	Publish(string, []interface{}) error
	Call(string, []interface{}, []interface{}) (uint, error)

	Unsubscribe(string) error
	Unregister(string) error

	Join(Connection)
	Leave()
}

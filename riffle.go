package core

// Global interfaces and public configuration

// The reeceiving end
type Delegate interface {
	Invoke(uint, []interface{}) ([]interface{}, error)
	OnJoin(string)
	OnLeave(string)
}

type Domain interface {
	Subscribe(string, []interface{}) error
	Register(string, []interface{}) error

	Publish(string, []interface{}) error
	Call(string, []interface{}) ([]interface{}, error)
    Yield(uint, []interface{})

	Unsubscribe(string) error
	Unregister(string) error

	Join(Connection) error
	Leave() error
}

type Persistence interface {
	Load(string, []byte)
	Save(string, []byte)
}

// Interface to external connection implementations
type Connection interface {
	// Send a message
	Send([]byte)

	// Called with a reason for the close
	Close(string) error
}

// Manages a set of domains, receives messages from the wrapper's connections
type App interface {
	NewDomain(string, Delegate) Domain

	ReceiveBytes([]byte)
	ReceiveString(string)
	ReceiveMessage(message)

	Close(string)
}

const (
	LocalFabric      string = "ws://localhost:8000/ws"
	DevFabric        string = "ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws"
	SandboxFabric    string = "ws://sandbox.exis.io/ws"
	ProudctionFabric string = "wss://node.exis.io/wss"

	LogLevelErr   int = 0
	LogLevelWarn  int = 1
	LogLevelInfo  int = 2
	LogLevelDebug int = 3
)

// Injectible writer
type LogWriter interface {
	Write(string)
}

// The mantles set these
var LogLevel int = 0
var writer LogWriter

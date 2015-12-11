package core

// Global interfaces and public configuration

// Manages a set of domains, receives messages from the wrapper's connections
type App interface {
	NewDomain(string) Domain

	ReceiveBytes([]byte)
	ReceiveString(string)
	ReceiveMessage(message)

	Close(string)
	CallbackListen() Callback
	CallbackSend(uint, []interface{})
}

type Domain interface {
	Subscribe(string, uint, []interface{}) error
	Register(string, uint, []interface{}) error
	Publish(string, uint, []interface{}) error
	Call(string, uint, []interface{}) error

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

// The mantles set these (maybe?)
var LogLevel int = 0
var writer LogWriter

package core

// Global interfaces and public configuration

// The reeceiving end
type Delegate interface {
	// Called by core when something needs doing
	Invoke(string, uint, []interface{}) ([]interface{}, error)

	OnJoin(string)
	OnLeave(string)
}

type Domain interface {
	Subscribe(string, []interface{}) (uint, error)
	Register(string, []interface{}) (uint, error)

	Publish(string, []interface{}) error
	Call(string, []interface{}) ([]interface{}, error)

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

	// Closes the peer connection and any channel returned from Receive().
	// Calls with a reason for the close
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

// Injectible writer
type LogWriter interface {
	Write(string)
}

const (
	LocalFabric      string = "ws://localhost:8000/ws"
	DevFabric        string = "ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws"
	SandboxFabric    string = "ws://sandbox.exis.io/ws"
	ProudctionFabric string = "wss://node.exis.io/wss"

	levelErr   int = 0
	levelWarn  int = 1
	levelInfo  int = 2
	levelDebug int = 3
)

var logLevel int = 0
var writer LogWriter

func SetLoggingDebug() {
	logLevel = levelDebug
}

func SetLoggingInfo() {
	logLevel = levelInfo
}

func SetLoggingWarn() {
	logLevel = levelWarn
}

func SetLogWriter(w LogWriter) {
	writer = w
}

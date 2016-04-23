package core

import (
	"fmt"
	"math/rand"
	"time"
)

type Connection interface {
	Send([]byte) error
	Close(string) error
	SetApp(App)
	IsOpen() bool
}

// Factory for creating new connections. If the AppDomain is not
// explictly passed an open connection it invokes this factory to create new connections
type ConnectionFactory interface {
	Open(string) (Connection, error)
}

// An external generator of ids based on platform differences
type IdGenerator interface {
	NewID() uint64
}

const (
	maxId          int64         = 1 << 53
	MessageTimeout time.Duration = 3 * time.Hour

	FabricLocal      = "ws://localhost:8000/ws"
	FabricDev        = "ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws"
	FabricSandbox    = "ws://sandbox.exis.io:8000/ws"
	FabricProduction = "wss://node.exis.io:8000/wss"

	RegistrarLocal      = "http://localhost:8880"
	RegistrarDev        = "http://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8880"
	RegistrarProduction = "https://node.exis.io:8880"

	CuminStrict = 2
	CuminLoose  = 1
	CuminOff    = 0

	LogLevelOff   int = 0
	LogLevelApp   int = 1
	LogLevelErr   int = 2
	LogLevelWarn  int = 3
	LogLevelInfo  int = 4
	LogLevelDebug int = 5

	Disconnected = iota
	Connected
	Ready
	Leaving

	// Exponential backoff settings
	//
	// initialRetryDelay is used for the first reconnection after startup and after
	// a successful connection (0 means try again immediately).
	//
	// Subsequent retries will use delays that grow exponentially between
	// minRetryDelay and maxRetryDelay.

	initialRetryDelay = 0 * time.Second
	minRetryDelay     = 1 * time.Second
	maxRetryDelay     = 30 * time.Second
)

var (
	LogLevel      int    = 1
	Fabric        string = FabricProduction
	Registrar     string = RegistrarProduction
	CuminLevel    int    = CuminLoose
	UseUnsafeCert bool   = false

	ShouldLogLineNumber = true // Print the line that emitted the log

	// If this is set, core relies on this to generate IDs instead of its own logic
	ExternalGenerator        IdGenerator       = nil
    DefaultConnectionFactory ConnectionFactory = nil
)

func NewID() uint64 {
	if ExternalGenerator != nil {
		return ExternalGenerator.NewID()
	}

	return uint64(rand.Int63n(maxId))
}

func formatUnexpectedMessage(msg message, expected string) string {
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
		s += fmt.Sprintf(" %s=%v", k, v)
	}
	return s
}

// Some data structure utility methods
func bindingForEndpoint(bindings map[uint64]*boundEndpoint, endpoint string) (uint64, *boundEndpoint, bool) {
	for id, p := range bindings {
		if p.endpoint == endpoint {
			return id, p, true
		}
	}

	return 0, nil, false
}

func removeDomain(domains []*domain, target *domain) ([]*domain, bool) {
	for i, e := range domains {
		if e == target {
			return append(domains[:i], domains[i+1:]...), true
		}
	}

	return nil, false
}

func SetLogLevelOff()   { LogLevel = LogLevelOff }
func SetLogLevelApp()   { LogLevel = LogLevelApp }
func SetLogLevelErr()   { LogLevel = LogLevelErr }
func SetLogLevelWarn()  { LogLevel = LogLevelWarn }
func SetLogLevelInfo()  { LogLevel = LogLevelInfo }
func SetLogLevelDebug() { LogLevel = LogLevelDebug }

func SetCuminStrict() { CuminLevel = CuminStrict }
func SetCuminLoose()  { CuminLevel = CuminLoose }
func SetCuminOff()    { CuminLevel = CuminOff }

func SetFabricSandbox() {
	Fabric = FabricSandbox
}

func SetFabricDev() {
	Fabric = FabricDev
	Registrar = RegistrarDev
}

func SetFabricProduction() {
	Fabric = FabricProduction
	Registrar = RegistrarProduction
}

func SetFabricLocal() {
	Fabric = FabricLocal
	Registrar = RegistrarLocal
}

func SetConnectionFactory(f ConnectionFactory) error {
	DefaultConnectionFactory = f
	return nil
}

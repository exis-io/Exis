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
}

// An external generator of ids based on platform differences
type IdGenerator interface {
	NewID() uint64
}

// If this is set, core relies on this to generate IDs instead of its own logic
var ExternalGenerator IdGenerator = nil

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
)

var (
	LogLevel      int    = 1
	Fabric        string = FabricProduction
	Registrar     string = RegistrarProduction
	CuminLevel    int    = CuminLoose
	UseUnsafeCert bool   = false
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

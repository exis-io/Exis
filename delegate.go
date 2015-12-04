package coreRiffle

// Keeps track of all the domains and handles message passing between them

// The representation of a domain from the perspective of the wrapper.
type Delegate interface {

	// Called by core when something needs doing
	Invoke(uint, []interface{}, map[string]interface{})

	OnJoin()
	OnLeave()
}

type delegate struct {
}

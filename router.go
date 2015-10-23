package riffle

type Router struct {
}

func NewDefaultRouter() Router {
	return Router{}
}

// returns the pdid of the next hop on the path for the given message
func (router *Router) Route(msg *Message) string {
	// Is target a tenant?
	// Is target in forwarding tables?
	// Ask map for next hop

	return ""
}

package riffle

// Holds stored certificates, contacts the auth appliance, etc
type Author struct {
	permissions map[string]string
}

func NewAuthor() Author {
	return Author{}
}

// func (author *Author) Permitted(endpoint URI, sess *Session) bool {
// 	// TODO: allow all core appliances to perform whatever they want
// 	if sess.pdid == "pd.bouncer" || sess.pdid == "pd.map" || sess.pdid == "pd.auth" {
// 		return true
// 	}

// 	// The node is always permitted to perform any action
// 	if sess.pdid == n.agent.pdid {
// 		return true
// 	}

// 	return true

// 	// Is downward action? allow
// 	if val := subdomain(string(sess.pdid), string(endpoint)); val {
// 		return val
// 	}

// 	// Check permissions cache: if found, allow

// 	// Check with bouncer on permissions check
// 	if bouncerActive := n.Dealer.hasRegistration("pd.bouncer/checkPerm"); bouncerActive {
// 		args := []interface{}{string(sess.pdid), string(endpoint)}

// 		ret, err := n.agent.Call("pd.bouncer/checkPerm", args, nil)

// 		if err != nil {
// 			out.Critical("Error, returning true: %s", err)
// 			return true
// 		}

// 		if permitted, ok := ret.Arguments[0].(bool); ok {
// 			// out.Debug("Bouncer returning %s", permitted)
// 			// TODO: save a permitted action in some flavor of cache
// 			return permitted
// 		} else {
// 			out.Critical("Could not extract permission from return val. Bouncer called and returnd: %s", ret.Arguments)
// 			return true
// 		}
// 	} else {
// 		out.Warning("No bouncer registered!")
// 	}

// 	// Action is not permitted
// 	return false
// }

package riffle

import (
	"strconv"
	"sync"
)

// A broker handles routing EVENTS from Publishers to Subscribers.
type Broker interface {
	// Publishes a message to all Subscribers.
	Publish(Sender, *Publish)
	// Subscribes to messages on a URI.
	Subscribe(Sender, *Subscribe)
	// Unsubscribes from messages on a URI.
	Unsubscribe(Sender, *Unsubscribe)
	dump() string
	hasSubscription(string) bool
	lostSession(*Session)
}

// A super simple broker that matches URIs to Subscribers.
type defaultBroker struct {
	routes map[URI]map[ID]Sender

	// Keep track of subscriptions by session, so that we can clean up when the
	// session closes.  For each session, we have a map[ID]URI, which maps
	// subscription ID to the endpoint.
	subscriptions map[Sender]map[ID]URI

	// Use this mutex to protect all accesses to the routes and subscriptions
	// maps.
	subMutex sync.Mutex
}

// NewDefaultBroker initializes and returns a simple broker that matches URIs to Subscribers.
func NewDefaultBroker() Broker {
	return &defaultBroker{
		routes:        make(map[URI]map[ID]Sender),
		subscriptions: make(map[Sender]map[ID]URI),
	}
}

// Publish sends a message to all subscribed clients except for the sender.
//
// If msg.Options["acknowledge"] == true, the publisher receives a Published event
// after the message has been sent to all subscribers.
func (br *defaultBroker) Publish(pub Sender, msg *Publish) {
	pubId := NewID()

	evtTemplate := Event{
		Publication: pubId,
		Arguments:   msg.Arguments,
		ArgumentsKw: msg.ArgumentsKw,
		Details:     make(map[string]interface{}),
	}

	// Make a copy of the subscriber list so we don't hold the lock during the
	// send calls.
	subs := make(map[ID]Sender)
	br.subMutex.Lock()
	for id, sub := range br.routes[msg.Topic] {
		// don't send event to publisher
		if sub != pub {
			subs[id] = sub
		}
	}
	br.subMutex.Unlock()

	for id, sub := range subs {
		// shallow-copy the template
		event := evtTemplate
		event.Subscription = id
		sub.Send(&event)
	}

	// only send published message if acknowledge is present and set to true
	if doPub, _ := msg.Options["acknowledge"].(bool); doPub {
		pub.Send(&Published{Request: msg.Request, Publication: pubId})
	}
}

// Subscribe subscribes the client to the given topic.
func (br *defaultBroker) Subscribe(sub Sender, msg *Subscribe) {
	br.subMutex.Lock()

	if _, ok := br.routes[msg.Topic]; !ok {
		br.routes[msg.Topic] = make(map[ID]Sender)
	}

	id := NewID()
	br.routes[msg.Topic][id] = sub

	if br.subscriptions[sub] == nil {
		br.subscriptions[sub] = make(map[ID]URI)
	}
	br.subscriptions[sub][id] = msg.Topic

	br.subMutex.Unlock()

	sub.Send(&Subscribed{Request: msg.Request, Subscription: id})
}

func (br *defaultBroker) Unsubscribe(sub Sender, msg *Unsubscribe) {
	br.subMutex.Lock()

	topic, ok := br.subscriptions[sub][msg.Subscription]
	if !ok {
		br.subMutex.Unlock()

		err := &Error{
			Type:    msg.MessageType(),
			Request: msg.Request,
			Error:   ErrNoSuchSubscription,
		}
		sub.Send(err)
		//log.Printf("Error unsubscribing: no such subscription %v", msg.Subscription)
		return
	}

	delete(br.subscriptions[sub], msg.Subscription)

	if r, ok := br.routes[topic]; !ok {
		//log.Printf("Error unsubscribing: unable to find routes for %s topic", topic)
	} else if _, ok := r[msg.Subscription]; !ok {
		//log.Printf("Error unsubscribing: %s route does not exist for %v subscription", topic, msg.Subscription)
	} else {
		delete(r, msg.Subscription)
		if len(r) == 0 {
			delete(br.routes, topic)
		}
	}

	br.subMutex.Unlock()

	sub.Send(&Unsubscribed{Request: msg.Request})
}

// Remove all the subs for a session that has disconected
func (br *defaultBroker) lostSession(sess *Session) {
	br.subMutex.Lock()

	for id, topic := range br.subscriptions[sess] {
		out.Debug("Unsubscribe: %s from %s", sess, string(topic))
		delete(br.subscriptions[sess], id)
		delete(br.routes[topic], id)
	}

	delete(br.subscriptions, sess)

	br.subMutex.Unlock()
}

func (b *defaultBroker) dump() string {
	ret := "  routes:"

	for k, v := range b.routes {
		ret += "\n\t" + string(k)

		for x, _ := range v {
			ret += "\n\t  " + strconv.FormatUint(uint64(x), 16)
		}
	}

	ret += "\n  subs:"

	for sub, _ := range b.subscriptions {
		for k, v := range b.subscriptions[sub] {
			ret += "\n\t" + strconv.FormatUint(uint64(k), 16) + ": " + string(v)
		}
	}

	return ret
}

// Testing. Not sure if this works 100 or not
func (b *defaultBroker) hasSubscription(s string) bool {
	b.subMutex.Lock()
	_, exists := b.routes[URI(s)]
	b.subMutex.Unlock()
	return exists
}

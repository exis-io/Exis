package core

// Message is a generic container for a WAMP message.
type message interface {
	messageType() messageType
}

type messageType int

func (mt messageType) New() message {
	switch mt {
	case hELLO:
		return new(hello)
	case wELCOME:
		return new(welcome)
	case aBORT:
		return new(abort)
	case cHALLENGE:
		return new(challenge)
	case aUTHENTICATE:
		return new(authenticate)
	case gOODBYE:
		return new(goodbye)
	case hEARTBEAT:
		return new(heartbeat)
	case eRROR:
		return new(errorMessage)

	case pUBLISH:
		return new(publish)
	case pUBLISHED:
		return new(published)

	case sUBSCRIBE:
		return new(subscribe)
	case sUBSCRIBED:
		return new(subscribed)
	case uNSUBSCRIBE:
		return new(unsubscribe)
	case uNSUBSCRIBED:
		return new(unsubscribed)
	case eVENT:
		return new(event)

	case cALL:
		return new(call)
	case cANCEL:
		return new(cancel)
	case rESULT:
		return new(result)

	case rEGISTER:
		return new(register)
	case rEGISTERED:
		return new(registered)
	case uNREGISTER:
		return new(unregister)
	case uNREGISTERED:
		return new(unregistered)
	case iNVOCATION:
		return new(invocation)
	case iNTERRUPT:
		return new(interrupt)
	case yIELD:
		return new(yield)
	default:
		return nil
	}
}

func (mt messageType) String() string {
	switch mt {
	case hELLO:
		return "HELLO"
	case wELCOME:
		return "WELCOME"
	case aBORT:
		return "ABORT"
	case cHALLENGE:
		return "CHALLENGE"
	case aUTHENTICATE:
		return "AUTHENTICATE"
	case gOODBYE:
		return "GOODBYE"
	case hEARTBEAT:
		return "HEARTBEAT"
	case eRROR:
		return "ERROR"

	case pUBLISH:
		return "PUBLISH"
	case pUBLISHED:
		return "PUBLISHED"

	case sUBSCRIBE:
		return "SUBSCRIBE"
	case sUBSCRIBED:
		return "SUBSCRIBED"
	case uNSUBSCRIBE:
		return "UNSUBSCRIBE"
	case uNSUBSCRIBED:
		return "UNSUBSCRIBED"
	case eVENT:
		return "EVENT"

	case cALL:
		return "CALL"
	case cANCEL:
		return "CANCEL"
	case rESULT:
		return "RESULT"

	case rEGISTER:
		return "REGISTER"
	case rEGISTERED:
		return "REGISTERED"
	case uNREGISTER:
		return "UNREGISTER"
	case uNREGISTERED:
		return "UNREGISTERED"
	case iNVOCATION:
		return "INVOCATION"
	case iNTERRUPT:
		return "INTERRUPT"
	case yIELD:
		return "YIELD"
	default:
		panic("Invalid message type")
	}
}

const (
	hELLO        messageType = 1
	wELCOME      messageType = 2
	aBORT        messageType = 3
	cHALLENGE    messageType = 4
	aUTHENTICATE messageType = 5
	gOODBYE      messageType = 6
	hEARTBEAT    messageType = 7
	eRROR        messageType = 8

	pUBLISH   messageType = 16 //	Tx 	Rx
	pUBLISHED messageType = 17 //	Rx 	Tx

	sUBSCRIBE    messageType = 32 //	Rx 	Tx
	sUBSCRIBED   messageType = 33 //	Tx 	Rx
	uNSUBSCRIBE  messageType = 34 //	Rx 	Tx
	uNSUBSCRIBED messageType = 35 //	Tx 	Rx
	eVENT        messageType = 36 //	Tx 	Rx

	cALL   messageType = 48 //	Tx 	Rx
	cANCEL messageType = 49 //	Tx 	Rx
	rESULT messageType = 50 //	Rx 	Tx

	rEGISTER     messageType = 64 //	Rx 	Tx
	rEGISTERED   messageType = 65 //	Tx 	Rx
	uNREGISTER   messageType = 66 //	Rx 	Tx
	uNREGISTERED messageType = 67 //	Tx 	Rx
	iNVOCATION   messageType = 68 //	Tx 	Rx
	iNTERRUPT    messageType = 69 //	Tx 	Rx
	yIELD        messageType = 70 //	Rx 	Tx
)

// const messages map[int]string = map[int]string{
// 	hELLO:        1,
// 	wELCOME:      2,
// 	aBORT:        3,
// 	cHALLENGE:    4,
// 	aUTHENTICATE: 5,
// 	gOODBYE:      6,
// 	hEARTBEAT:    7,
// 	eRROR:        8,

// 	pUBLISH:   16,
// 	pUBLISHED: 17,

// 	sUBSCRIBE:    32,
// 	sUBSCRIBED:   33,
// 	uNSUBSCRIBE:  34,
// 	uNSUBSCRIBED: 35,
// 	eVENT:        36,

// 	cALL:   48,
// 	cANCEL: 49,
// 	rESULT: 50,

// 	rEGISTER:     64,
// 	rEGISTERED:   65,
// 	uNREGISTER:   66,
// 	uNREGISTERED: 67,
// 	iNVOCATION:   68,
// 	iNTERRUPT:    69,
// 	yIELD:        70,
// }

// [hELLO, Realm|uri, Details|dict]
type hello struct {
	Realm   string
	Details map[string]interface{}
}

func (msg *hello) messageType() messageType {
	return hELLO
}

// [wELCOME, Session|id, Details|dict]
type welcome struct {
	Id      uint
	Details map[string]interface{}
}

func (msg *welcome) messageType() messageType {
	return wELCOME
}

// [aBORT, Details|dict, Reason|uri]
type abort struct {
	Details map[string]interface{}
	Reason  string
}

func (msg *abort) messageType() messageType {
	return aBORT
}

// [cHALLENGE, AuthMethod|string, Extra|dict]
type challenge struct {
	AuthMethod string
	Extra      map[string]interface{}
}

func (msg *challenge) messageType() messageType {
	return cHALLENGE
}

// [aUTHENTICATE, Signature|string, Extra|dict]
type authenticate struct {
	Signature string
	Extra     map[string]interface{}
}

func (msg *authenticate) messageType() messageType {
	return aUTHENTICATE
}

// [gOODBYE, Details|dict, Reason|uri]
type goodbye struct {
	Details map[string]interface{}
	Reason  string
}

func (msg *goodbye) messageType() messageType {
	return gOODBYE
}

// [hEARTBEAT, IncomingSeq|integer, OutgoingSeq|integer
// [hEARTBEAT, IncomingSeq|integer, OutgoingSeq|integer, Discard|string]
type heartbeat struct {
	IncomingSeq uint
	OutgoingSeq uint
	Discard     string
}

func (msg *heartbeat) messageType() messageType {
	return hEARTBEAT
}

// [eRROR, REQUEST.Type|int, REQUEST.Request|id, Details|dict, Error|uri]
// [eRROR, REQUEST.Type|int, REQUEST.Request|id, Details|dict, Error|uri, Arguments|list]
// [eRROR, REQUEST.Type|int, REQUEST.Request|id, Details|dict, Error|uri, Arguments|list, ArgumentsKw|dict]
type errorMessage struct {
	Type        messageType
	Request     uint
	Details     map[string]interface{}
	Error       string
	Arguments   []interface{}          `wamp:"omitempty"`
	ArgumentsKw map[string]interface{} `wamp:"omitempty"`
}

func (msg *errorMessage) messageType() messageType {
	return eRROR
}

// [pUBLISH, Request|id, Options|dict, name|uri]
// [pUBLISH, Request|id, Options|dict, name|uri, Arguments|list]
// [pUBLISH, Request|id, Options|dict, name|uri, Arguments|list, ArgumentsKw|dict]
type publish struct {
	Request     uint
	Options     map[string]interface{}
	Name        string
	Arguments   []interface{}          `wamp:"omitempty"`
	ArgumentsKw map[string]interface{} `wamp:"omitempty"`
}

func (msg *publish) messageType() messageType {
	return pUBLISH
}

// [pUBLISHED, pUBLISH.Request|id, Publication|id]
type published struct {
	Request     uint
	Publication uint
}

func (msg *published) messageType() messageType {
	return pUBLISHED
}

// [sUBSCRIBE, Request|id, Options|dict, name|uri]
type subscribe struct {
	Request uint
	Options map[string]interface{}
	Name    string
}

func (msg *subscribe) messageType() messageType {
	return sUBSCRIBE
}

// [sUBSCRIBED, sUBSCRIBE.Request|id, Subscription|id]
type subscribed struct {
	Request      uint
	Subscription uint
}

func (msg *subscribed) messageType() messageType {
	return sUBSCRIBED
}

// [uNSUBSCRIBE, Request|id, sUBSCRIBED.Subscription|id]
type unsubscribe struct {
	Request      uint
	Subscription uint
}

func (msg *unsubscribe) messageType() messageType {
	return uNSUBSCRIBE
}

// [uNSUBSCRIBED, uNSUBSCRIBE.Request|id]
type unsubscribed struct {
	Request uint
}

func (msg *unsubscribed) messageType() messageType {
	return uNSUBSCRIBED
}

// [eVENT, sUBSCRIBED.Subscription|id, pUBLISHED.Publication|id, Details|dict]
// [eVENT, sUBSCRIBED.Subscription|id, pUBLISHED.Publication|id, Details|dict, pUBLISH.Arguments|list]
// [eVENT, sUBSCRIBED.Subscription|id, pUBLISHED.Publication|id, Details|dict, pUBLISH.Arguments|list,
//     pUBLISH.ArgumentsKw|dict]
type event struct {
	Subscription uint
	Publication  uint
	Details      map[string]interface{}
	Arguments    []interface{}          `wamp:"omitempty"`
	ArgumentsKw  map[string]interface{} `wamp:"omitempty"`
}

func (msg *event) messageType() messageType {
	return eVENT
}

// CallResult represents the result of a cALL.
type callResult struct {
	Args   []interface{}
	Kwargs map[string]interface{}
	Err    string
}

// [cALL, Request|id, Options|dict, name|uri]
// [cALL, Request|id, Options|dict, name|uri, Arguments|list]
// [cALL, Request|id, Options|dict, name|uri, Arguments|list, ArgumentsKw|dict]
type call struct {
	Request     uint
	Options     map[string]interface{}
	Name        string
	Arguments   []interface{}          `wamp:"omitempty"`
	ArgumentsKw map[string]interface{} `wamp:"omitempty"`
}

func (msg *call) messageType() messageType {
	return cALL
}

// [rESULT, cALL.Request|id, Details|dict]
// [rESULT, cALL.Request|id, Details|dict, yIELD.Arguments|list]
// [rESULT, cALL.Request|id, Details|dict, yIELD.Arguments|list, yIELD.ArgumentsKw|dict]
type result struct {
	Request     uint
	Details     map[string]interface{}
	Arguments   []interface{}          `wamp:"omitempty"`
	ArgumentsKw map[string]interface{} `wamp:"omitempty"`
}

func (msg *result) messageType() messageType {
	return rESULT
}

// [rEGISTER, Request|id, Options|dict, name|uri]
type register struct {
	Request uint
	Options map[string]interface{}
	Name    string
}

func (msg *register) messageType() messageType {
	return rEGISTER
}

// [rEGISTERED, rEGISTER.Request|id, Registration|id]
type registered struct {
	Request      uint
	Registration uint
}

func (msg *registered) messageType() messageType {
	return rEGISTERED
}

// [uNREGISTER, Request|id, rEGISTERED.Registration|id]
type unregister struct {
	Request      uint
	Registration uint
}

func (msg *unregister) messageType() messageType {
	return uNREGISTER
}

// [uNREGISTERED, uNREGISTER.Request|id]
type unregistered struct {
	Request uint
}

func (msg *unregistered) messageType() messageType {
	return uNREGISTERED
}

// [iNVOCATION, Request|id, rEGISTERED.Registration|id, Details|dict]
// [iNVOCATION, Request|id, rEGISTERED.Registration|id, Details|dict, cALL.Arguments|list]
// [iNVOCATION, Request|id, rEGISTERED.Registration|id, Details|dict, cALL.Arguments|list, cALL.ArgumentsKw|dict]
type invocation struct {
	Request      uint
	Registration uint
	Details      map[string]interface{}
	Arguments    []interface{}          `wamp:"omitempty"`
	ArgumentsKw  map[string]interface{} `wamp:"omitempty"`
}

func (msg *invocation) messageType() messageType {
	return iNVOCATION
}

// [yIELD, iNVOCATION.Request|id, Options|dict]
// [yIELD, iNVOCATION.Request|id, Options|dict, Arguments|list]
// [yIELD, iNVOCATION.Request|id, Options|dict, Arguments|list, ArgumentsKw|dict]
type yield struct {
	Request     uint
	Options     map[string]interface{}
	Arguments   []interface{}          `wamp:"omitempty"`
	ArgumentsKw map[string]interface{} `wamp:"omitempty"`
}

func (msg *yield) messageType() messageType {
	return yIELD
}

// [cANCEL, cALL.Request|id, Options|dict]
type cancel struct {
	Request uint
	Options map[string]interface{}
}

func (msg *cancel) messageType() messageType {
	return cANCEL
}

// [iNTERRUPT, iNVOCATION.Request|id, Options|dict]
type interrupt struct {
	Request uint
	Options map[string]interface{}
}

func (msg *interrupt) messageType() messageType {
	return iNTERRUPT
}

type NoDestinationError string

func (e NoDestinationError) Error() string {
	return "cannot determine destination from: " + string(e)
}

// Given a message, return the intended endpoint
func destination(m *message) (string, error) {
	msg := *m

	switch msg := msg.(type) {

	case *publish:
		return msg.Name, nil
	case *subscribe:
		return msg.Name, nil

	// Dealer messages
	case *register:
		return msg.Name, nil
	case *call:
		return msg.Name, nil

	default:
		//log.Println("Unhandled message:", msg.messageType())
		return "", NoDestinationError(msg.messageType())
	}
}

// Given a message, return the request uint
func requestID(m message) (uint, bool) {
	switch msg := (m).(type) {
	case *registered:
		return msg.Request, true
	case *subscribed:
		return msg.Request, true
	case *unsubscribed:
		return msg.Request, true
	case *unregistered:
		return msg.Request, true
	case *unsubscribe:
		return msg.Request, true
	case *unregister:
		return msg.Request, true
	case *result:
		return msg.Request, true
	case *errorMessage:
		return msg.Request, true
	case *publish:
		return msg.Request, true
	case *subscribe:
		return msg.Request, true
	case *register:
		return msg.Request, true
	case *call:
		return msg.Request, true
	default:
		Warn("Cant get requestID for %s: %v", msg.messageType(), m)
		return 0, false
	}
}

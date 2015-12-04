package coreRiffle

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
		// TODO: allow custom message types?
		return nil
	}
}

func (mt messageType) String() string {
	switch mt {
	case hELLO:
		return "hELLO"
	case wELCOME:
		return "wELCOME"
	case aBORT:
		return "aBORT"
	case cHALLENGE:
		return "cHALLENGE"
	case aUTHENTICATE:
		return "aUTHENTICATE"
	case gOODBYE:
		return "gOODBYE"
	case hEARTBEAT:
		return "hEARTBEAT"
	case eRROR:
		return "eRROR"

	case pUBLISH:
		return "pUBLISH"
	case pUBLISHED:
		return "pUBLISHED"

	case sUBSCRIBE:
		return "sUBSCRIBE"
	case sUBSCRIBED:
		return "sUBSCRIBED"
	case uNSUBSCRIBE:
		return "uNSUBSCRIBE"
	case uNSUBSCRIBED:
		return "uNSUBSCRIBED"
	case eVENT:
		return "eVENT"

	case cALL:
		return "cALL"
	case cANCEL:
		return "cANCEL"
	case rESULT:
		return "rESULT"

	case rEGISTER:
		return "rEGISTER"
	case rEGISTERED:
		return "rEGISTERED"
	case uNREGISTER:
		return "uNREGISTER"
	case uNREGISTERED:
		return "uNREGISTERED"
	case iNVOCATION:
		return "iNVOCATION"
	case iNTERRUPT:
		return "iNTERRUPT"
	case yIELD:
		return "yIELD"
	default:
		// TODO: allow custom message types?
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

////////////////////////////////////////
/*
 Begin a whole mess of code we really don't want to get into
 and which pretty much guarantees we'll have to make substantial changes to
 Riffle code: the messages don't have a standardized way of returning their
 TO identity!

 Really, really need this, Short of modifying and standardizing the WAMP changes
 this is unlikely to happen without node monkey-patching. So here we go.
*/
////////////////////////////////////////

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
func requestID(m *message) uint {
	switch msg := (*m).(type) {
	case *publish:
		return msg.Request
	case *subscribe:
		return msg.Request
	case *register:
		return msg.Request
	case *call:
		return msg.Request
	}

	return uint(0)
}

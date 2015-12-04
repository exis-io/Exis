package goriffle

import (
	"encoding/json"
	"fmt"
	"log"
	"strconv"
)

var sess *session

var mem chan message
var kill chan uint

// Create a global session
func PConnector(url string, domain string) string {
	s, err := Start(url, domain)
	sess = s

	if err != nil {
		fmt.Println(err)
		return "NO"
	}

	go internalReceive()

	mem = make(chan message)
	kill = make(chan uint)

	return "YES"
}

// func Test() map[string]interface{} {
// 	return map[string]interface{}{
// 		"id": true,
// 	}
// }

// Might not have to use PSubscribe at all, actually.
// Make the regular methods return their ids and toggle on
// the custom receiver loop
func PSubscribe(s string) []byte {
	// Ooh, this is tricky. Can't really have this here
	e := sess.Subscribe(s, nil)

	if e != nil {
		fmt.Println("GR: error subscribing: ", e)
	}

	if i, _, ok := bindingForEndpoint(sess.events, s); ok {
		fmt.Println("Subscribed for endpoint: ", int(i))
		return marshall(i)
	} else {
		fmt.Println("GR: WARN-- no subscription found for ", s)
		return nil
	}
}

func PRegister(s string) []byte {
	sess.Register(s, nil, map[string]interface{}{})

	if i, _, ok := bindingForEndpoint(sess.procedures, s); ok {
		fmt.Println("Registered for endpoint: ", int(i))
		return marshall(i)
	} else {
		fmt.Println("GR: WARN-- no registration found for ", s)
		return nil
	}
}

// Cant return an int safely!
func PRecieve() []byte {
	var m message
	//fmt.Println("GR: receive loop")

	select {
	case m = <-mem:
		switch msg := m.(type) {

		case *event:
			return marshall(map[string]interface{}{
				"id":   msg.Subscription,
				"data": msg.Arguments,
			})

		case *invocation:
			// fmt.Println("GR: invocation: ", msg)

			return marshall(map[string]interface{}{
				"id":      msg.Registration,
				"request": msg.Request,
				"data":    msg.Arguments,
			})

		default:
			log.Println("unhandled message:", msg.messageType(), msg)
			panic("Unhandled message!")
		}

	case <-kill:
		fmt.Println("GR: kill received")
		return nil
	}
}

func PYield(args []byte) {
	var dat map[string]interface{}

	if err := json.Unmarshal(args, &dat); err != nil {
		panic(err)
	}

	strRequest, status, result := dat["id"].(string), dat["ok"].(string), dat["result"].([]interface{})
	j, _ := strconv.ParseUint(strRequest, 10, 64)
	request := uint(j)

	//fmt.Println("Yielding with: ", dat)

	var tosend message

	tosend = &yield{
		Request:   request,
		Options:   make(map[string]interface{}),
		Arguments: result,
	}

	if status != "" {
		tosend = &errorMessage{
			Type:      iNVOCATION,
			Request:   request,
			Details:   make(map[string]interface{}),
			Arguments: result,
			Error:     status,
		}
	}

	if err := sess.Send(tosend); err != nil {
		log.Println("error sending message:", err)
	}
}

func marshall(data interface{}) []byte {
	if r, e := json.Marshal(data); e == nil {
		return r
	} else {
		fmt.Println("GR: WARN-- unable to marshall args")
		return nil
	}
}

func internalReceive() {
	fmt.Println("Internal receive")

	c := sess
	for msg := range c.connection.Receive() {

		fmt.Println("GR: Internal MSG: ", msg)
		switch msg := msg.(type) {

		case *event:
			if _, ok := c.events[msg.Subscription]; ok {
				mem <- msg

			} else {
				log.Println("no handler registered for subscription:", msg.Subscription)
			}

		case *invocation:
			if _, ok := c.procedures[msg.Registration]; ok {
				mem <- msg

			} else {
				log.Println("no handler registered for registration:", msg.Registration)
			}

		case *registered:
			c.notifyListener(msg, msg.Request)
		case *subscribed:
			c.notifyListener(msg, msg.Request)
		case *unsubscribed:
			c.notifyListener(msg, msg.Request)
		case *unregistered:
			c.notifyListener(msg, msg.Request)
		case *result:
			c.notifyListener(msg, msg.Request)
		case *errorMessage:
			c.notifyListener(msg, msg.Request)

		case *goodbye:
			// fmt.Println("GR: Goodbye!")
			break

		default:
			log.Println("unhandled message:", msg.messageType(), msg)
			panic("Unhandled message!")
		}
	}

	fmt.Println("GR: Internal receive done")
}

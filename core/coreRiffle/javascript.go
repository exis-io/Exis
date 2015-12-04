package goriffle

import (
	"encoding/json"
	"fmt"
	"log"
)

// Create a global session
// func PConnector(url string, domain string) string {
// 	s, err := Start(url, domain)
// 	sess = s

// 	if err != nil {
// 		fmt.Println(err)
// 		return "NO"
// 	}

// 	go internalReceive()

// 	mem = make(chan message)
// 	kill = make(chan uint)

// 	return "YES"
// }

func (c *domain) ExternalReceive(msg string) {
	byt := []byte(msg)
	var dat []interface{}

	if err := json.Unmarshal(byt, &dat); err != nil {
		fmt.Println(err)
		return
	}

	seer := new(jSONSerializer)
	fmt.Println("Received a message: ", msg)

	m, err := seer.deserializeString(dat)
	if err != nil {
		log.Println("error deserializing message:", err)
		log.Println(msg)
	} else {
		fmt.Println("Message received!")
		c.Handle(m)
	}
}

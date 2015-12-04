package goriffle

import (
	"fmt"
	"math/rand"
	"time"
)

const (
	maxId int64 = 1 << 53
)

func init() {
	rand.Seed(time.Now().UnixNano())
}

// NewID generates a random WAMP uint.
func newID() uint {
	return uint(rand.Int63n(maxId))
}

// func PprintMap(m interface{}) {
// 	if b, err := jSON.MarshalIndent(m, "", "  "); err != nil {
// 		fmt.Println("error:", err)
// 	} else {
// 		//log.Printf("%s", string(m))
// 	}
// }

func formatUnexpectedMessage(msg message, expected messageType) string {
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
		// TODO: reflection to recursively check map
		s += fmt.Sprintf(" %s=%v", k, v)
	}
	return s
}

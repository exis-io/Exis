package riffle

import (
	"math/rand"
	"time"
)

const (
	maxId int64 = 1 << 53
)

func init() {
	rand.Seed(time.Now().UnixNano())
}

// NewID generates a random WAMP ID.
func NewID() ID {
	return ID(rand.Int63n(maxId))
}

// func PprintMap(m interface{}) {
// 	if b, err := json.MarshalIndent(m, "", "  "); err != nil {
// 		fmt.Println("error:", err)
// 	} else {
// 		//log.Printf("%s", string(m))
// 	}
// }

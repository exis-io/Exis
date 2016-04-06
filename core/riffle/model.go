package riffle

import (
	"github.com/exis-io/core"
)

// Riffle model implementation in Go
// EXPERIMENTAL!

// NOT MEANT TO BE EXPOSED TO goRiffle!
func TestCoreModels(m core.Model) {
	m.Query("collection/find", "Dog", nil)
	// m.Find("Dog", "")

	// m.Create("Dog", string(`{"name": "Jim"}`))

	// m.Find("Dog", "")
}

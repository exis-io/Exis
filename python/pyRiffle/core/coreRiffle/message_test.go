package goriffle

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestTarget(t *testing.T) {
	Convey("Destination is extracted for normal traffic", t, func() {
		Convey("When message is Publish", func() {
			// msg =
			So(validEndpoint("pd"), ShouldBeTrue)
		})
	})
}

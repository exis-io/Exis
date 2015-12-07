package goRiffle

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestCanRun(t *testing.T) {
	Convey("Test suite", t, func() {
		Convey("can run", func() {
			So(true, ShouldBeTrue)
		})
	})
}

package core

import (
	"strings"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestTrace(t *testing.T) {
	Convey("Trace should return nonempty string", t, func() {
		t := trace()
		So(t, ShouldNotEqual, "")
		So(strings.Contains(t, "convey.context"), ShouldBeTrue)
	})
}

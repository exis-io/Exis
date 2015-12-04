package riffle

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestCuminXNone(t *testing.T) {
	Convey("Functions that return nothing", t, func() {
		Convey("Should accept no args", func() {
			_, e := Cumin(noneNone, []interface{}{})
			So(e, ShouldBeNil)
		})

		Convey("Should accept one arg", func() {
			_, e := Cumin(oneNone, []interface{}{1})

			So(e, ShouldBeNil)
			// So(r[0] ShouldEqual, 1)
		})
	})
}

// Functions for cuminication
func noneNone()     {}
func oneNone(a int) {}

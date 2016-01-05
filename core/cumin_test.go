package core

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
		})
	})
}

func TestSoftCumin(t *testing.T) {
	Convey("Successful primitives checks", t, func() {
		Convey("Should accept ints", func() {
			var i float64 = 1
			e := softCumin([]interface{}{"float"}, []interface{}{i})
			So(e, ShouldBeNil)
		})
	})

	Convey("Failed primitives checks", t, func() {
		Convey("Should only accept numbers", func() {
			i := true
			e := softCumin([]interface{}{"float"}, []interface{}{i})
			So(e, ShouldNotBeNil)
		})
	})

	Convey("Invalid number of arguments", t, func() {
		Convey("Should fail", func() {
			e := softCumin([]interface{}{"float"}, []interface{}{})
			So(e, ShouldNotBeNil)
		})
	})
}

// Functions for cuminication
func noneNone()     {}
func oneNone(a int) {}

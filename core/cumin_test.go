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
	Convey("Invalid number of arguments", t, func() {
		Convey("Should fail", func() {
			So(softCumin([]interface{}{"float"}, []interface{}{}), ShouldNotBeNil)
		})
	})

	Convey("Successful primitives checks", t, func() {
		Convey("Should accept floats as floats", func() {
			var i float64 = 1
			So(softCumin([]interface{}{"float"}, []interface{}{i}), ShouldBeNil)
		})

		Convey("Should accept ints as floats", func() {
			var i int = 1
			So(softCumin([]interface{}{"float"}, []interface{}{i}), ShouldBeNil)
		})
	})

	Convey("Failed primitives checks", t, func() {
		Convey("Should only accept numbers", func() {
			i := true
			So(softCumin([]interface{}{"float"}, []interface{}{i}), ShouldNotBeNil)
		})
	})
}

// Functions for cuminication
func noneNone()     {}
func oneNone(a int) {}

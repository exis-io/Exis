package core

import (
	"testing"
    "encoding/json"
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
			So(softCumin([]interface{}{"float"}, jsonicate(i)), ShouldBeNil)
		})

		Convey("Should accept ints as floats", func() {
			var i int = 1
			So(softCumin([]interface{}{"float"}, jsonicate(i)), ShouldBeNil)
		})
	})

	Convey("Failed primitives checks", t, func() {
		Convey("Should not accept booleans as floats", func() {
			i := true
			So(softCumin([]interface{}{"float"}, jsonicate(i)), ShouldNotBeNil)
		})
	})

	Convey("Successful array checks", t, func() {
		Convey("Should accept arrays of primitives", func() {
			i := []int{1, 2}
			So(softCumin([]interface{}{[]string{"int"}}, jsonicate(i)), ShouldBeNil)
		})
	})

    Convey("Failed array checks", t, func() {
        Convey("Should not accept booleans as ints", func() {
            i := []bool{true, true, false}
            So(softCumin([]interface{}{[]string{"int"}}, []interface{}{i}), ShouldNotBeNil)
        })

        Convey("Should not accept non homogenous arrays", func() {
            i := []interface{}{1, true, false}
            So(softCumin([]interface{}{[]string{"int"}}, []interface{}{i}), ShouldNotBeNil)
        })
    })
}

// Functions for cuminication
func noneNone()     {}
func oneNone(a int) {}

// Run test arguments through a round of JSON
func jsonicate(args ...interface{}) []interface{} {
    var dat []interface{}
    j, _ := json.Marshal(args)
    if err := json.Unmarshal(j, &dat); err != nil {
        panic(err)
    }

    return dat
}
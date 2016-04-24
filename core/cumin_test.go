package core

import (
	"encoding/json"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestCuminUnpacking(t *testing.T) {
    Convey("Functions that return arguments", t, func() {
        f := func() []interface{} {
            return []interface{}{1, 2, 3}
        }

        Convey("Should output just those arguments", func() {
            q := []interface{}{1, 2, 3}

            r, e := Cumin(f, []interface{}{})
            So(len(r), ShouldEqual, len(q))
        })
    })
}

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
	Convey("When expecting anything", t, func() {
		Convey("Should accept ints", func() {
			So(SoftCumin(unmarshal(`[null]`), unmarshal(`[1]`)), ShouldBeNil)
		})
	})

	Convey("When checking number of arguments", t, func() {
		Convey("Should fail with insufficient arguments", func() {
			So(SoftCumin(unmarshal(`["float"]`), unmarshal(`[]`)), ShouldNotBeNil)
		})
	})

	Convey("When expecting primitives", t, func() {
		Convey("Should accept floats as floats", func() {
			So(SoftCumin(unmarshal(`["float"]`), unmarshal(`[1]`)), ShouldBeNil)
		})

		Convey("Should not accept booleans as floats", func() {
			So(SoftCumin(unmarshal(`["float"]`), unmarshal(`[true]`)), ShouldNotBeNil)
		})
	})

	Convey("When expecting arrays", t, func() {
		Convey("Should accept arrays of ints", func() {
			So(SoftCumin(unmarshal(`[["int"]]`), unmarshal(`[[1, 2]]`)), ShouldBeNil)
		})

		Convey("Should accept arrays of strings", func() {
			So(SoftCumin(unmarshal(`[["str"]]`), unmarshal(`[["alpha", "beta"]]`)), ShouldBeNil)
		})

		Convey("Should not accept booleans as ints", func() {
			So(SoftCumin(unmarshal(`[["int"]]`), unmarshal(`[[false, true, true]]`)), ShouldNotBeNil)

		})

		Convey("Should not accept heterogeneous array definitions", func() {
			So(SoftCumin(unmarshal(`[["int", "str"]]`), unmarshal(`[[1, "a"]]`)), ShouldNotBeNil)
		})

		Convey("Should not accept a map", func() {
			So(SoftCumin(unmarshal(`[["int", "str"]]`), unmarshal(`[{"a": 1}]`)), ShouldNotBeNil)
		})

		Convey("Should not accept non homogenous arrays", func() {
			So(SoftCumin(unmarshal(`[["int"]]`), unmarshal(`[[1, true, true]]`)), ShouldNotBeNil)
		})
	})

	Convey("When expecting dictionaries", t, func() {
		Convey("Should accept a simple object", func() {
			incoming := `[{"a":"alpha","b":1}]`
			expected := `[{"a":"str","b":"int"}]`

			So(SoftCumin(unmarshal(expected), unmarshal(incoming)), ShouldBeNil)
		})

		Convey("Should not accept bad types", func() {
			incoming := `[{"a":"alpha", "b":1}]`
			expected := `[{"a":"str", "b":"bool"}]`

			So(SoftCumin(unmarshal(expected), unmarshal(incoming)), ShouldNotBeNil)
		})

		Convey("Should not accept extra keys", func() {
			incoming := `[{"a":"alpha","b":1,"c":3}]`
			expected := `[{"a":"str","b":"int"}]`

			So(SoftCumin(unmarshal(expected), unmarshal(incoming)), ShouldNotBeNil)
		})
	})

	Convey("When expecting composite", t, func() {
		Convey("Should accept primitives, strings, and a dictionary", func() {
			incoming := `[1, ["Hey", "There"], {"a":"alpha","b":1}]`
			expected := `["int", ["str"], {"a":"str","b":"int"}]`

			So(SoftCumin(unmarshal(expected), unmarshal(incoming)), ShouldBeNil)
		})
	})

	Convey("Lists of objects", t, func() {
		expected := `[[{"name": "str"}]]`

		Convey("Should succeed for simple objects", func() {
			incoming := `[[{"name": "Dale"}, {"name": "Lance"}]]`
			So(SoftCumin(unmarshal(expected), unmarshal(incoming)), ShouldBeNil)
		})

		Convey("Should succeed for empty objects", func() {
			incoming := `[[]]`
			So(SoftCumin(unmarshal(expected), unmarshal(incoming)), ShouldBeNil)
		})

		Convey("Should not accept heterogeneous lists", func() {
			incoming := `[[{"name": "Dale"}, 5]]`
			So(SoftCumin(unmarshal(expected), unmarshal(incoming)), ShouldNotBeNil)
		})

		Convey("Should not accept bad types", func() {
			incoming := `[[{"name": "Dale"}, {"name": 3.14}]]`
			So(SoftCumin(unmarshal(expected), unmarshal(incoming)), ShouldNotBeNil)
		})

		Convey("Should not accept extraneous keys", func() {
			incoming := `[[{"name": "Dale", "cool": true}]]`
			So(SoftCumin(unmarshal(expected), unmarshal(incoming)), ShouldNotBeNil)
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

func unmarshal(literal string) []interface{} {
	var dat []interface{}
	if err := json.Unmarshal([]byte(literal), &dat); err != nil {
		panic(err)
	}

	return dat
}

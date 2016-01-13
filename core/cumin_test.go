package core

import (
	"encoding/json"
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
	Convey("When checking number of arguments", t, func() {
		Convey("Should fail with insufficient arguments", func() {
			So(softCumin(unmarshal(`["float"]`), unmarshal(`[]`)), ShouldNotBeNil)
		})
	})

	Convey("When expecting primitives", t, func() {
		Convey("Should accept floats as floats", func() {
			So(softCumin(unmarshal(`["float"]`), unmarshal(`[1]`)), ShouldBeNil)
		})

		Convey("Should not accept booleans as floats", func() {
			So(softCumin(unmarshal(`["float"]`), unmarshal(`[true]`)), ShouldNotBeNil)
		})
	})

	Convey("When expecting arrays", t, func() {
		Convey("Should accept arrays of ints", func() {
			So(softCumin(unmarshal(`[["int"]]`), unmarshal(`[[1, 2]]`)), ShouldBeNil)
		})

		Convey("Should accept arrays of strings", func() {
			So(softCumin(unmarshal(`[["str"]]`), unmarshal(`[["alpha", "beta"]]`)), ShouldBeNil)
		})

		Convey("Should not accept booleans as ints", func() {
			So(softCumin(unmarshal(`[["int"]]`), unmarshal(`[[false, true, true]]`)), ShouldNotBeNil)

		})

		Convey("Should not accept non homogenous arrays", func() {
			So(softCumin(unmarshal(`[["int"]]`), unmarshal(`[[1, true, true]]`)), ShouldNotBeNil)
		})
	})

	Convey("When expecting dictionaries", t, func() {
		Convey("Should accept a simple object", func() {
			incoming := `[{"a":"alpha","b":1}]`
			expected := `[{"a":"str","b":"int"}]`

			So(softCumin(unmarshal(expected), unmarshal(incoming)), ShouldBeNil)
		})

		Convey("Should not accept bad types", func() {
			incoming := `[{"a":"alpha", "b":1}]`
			expected := `[{"a":"str", "b":"bool"}]`

			So(softCumin(unmarshal(expected), unmarshal(incoming)), ShouldNotBeNil)
		})

		Convey("Should not accept extra keys", func() {
			incoming := `[{"a":"alpha","b":1,"c":3}]`
			expected := `[{"a":"str","b":"int"}]`

			So(softCumin(unmarshal(expected), unmarshal(incoming)), ShouldNotBeNil)
		})
	})

	Convey("When expecting composite", t, func() {
		Convey("Should accept primitives, strings, and a dictionary", func() {
			incoming := `[1, ["Hey", "There"], {"a":"alpha","b":1}]`
			expected := `["int", ["str"], {"a":"str","b":"int"}]`

			So(softCumin(unmarshal(expected), unmarshal(incoming)), ShouldBeNil)
		})
	})

	Convey("Lists of objects", t, func() {
		expected := `[[{"name": "str"}]]`

		Convey("Should succeed for simple objects", func() {
			incoming := `[[{"name": "Dale"}, {"name": "Lance"}]]`
			So(softCumin(unmarshal(expected), unmarshal(incoming)), ShouldBeNil)
		})

		Convey("Should succeed for empty objects", func() {
			incoming := `[[]]`
			So(softCumin(unmarshal(expected), unmarshal(incoming)), ShouldBeNil)
		})

		Convey("Should not accept heterogeneous lists", func() {
			incoming := `[[{"name": "Dale"}, 5]]`
			So(softCumin(unmarshal(expected), unmarshal(incoming)), ShouldNotBeNil)
		})

		Convey("Should not accept bad types", func() {
			incoming := `[[{"name": "Dale"}, {"name": 3.14}]]`
			So(softCumin(unmarshal(expected), unmarshal(incoming)), ShouldNotBeNil)
		})

		Convey("Should not accept extraneous keys", func() {
			incoming := `[[{"name": "Dale", "cool": true}]]`
			So(softCumin(unmarshal(expected), unmarshal(incoming)), ShouldNotBeNil)
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

package core

import (
    "testing"

    . "github.com/smartystreets/goconvey/convey"
)

func TestConstructors(t *testing.T) {
    s := NewSession()

    Convey("Functions that return a reference", t, func() {
        s.Send(`["NewApp", 10, 11, 12345, "xs.test"]`)

        Convey("Should create a memory reference to the new object", func() {
            So(len(s.memory), ShouldEqual, 2)

            _, ok := s.memory[12345]
            So(ok, ShouldBeTrue)
        })
    })
}

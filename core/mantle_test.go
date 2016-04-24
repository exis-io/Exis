package core

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestConstructors(t *testing.T) {
	s := NewSession()

	Convey("Functions that return a reference", t, func() {
		s.Send(`["NewApp", 10, 11, 12345, 0, "xs.test"]`)

		Convey("Should create a memory reference to the new object", func() {
			So(s.memory.Count(), ShouldEqual, 2)

			_, ok := s.memory.Get(12345)
			So(ok, ShouldBeTrue)
		})
	})
}

func TestCallbacks(t *testing.T) {
	s := NewSession()

	Convey("App callbacks should be bound to mantle dispatch", t, func() {
		s.Send(`["NewApp", 10, 11, 12345, 0, "xs.test"]`)
		<-s.dispatch

		a, _ := s.memory.Get(12345)
		app := a.(*app)

		app.CallbackSend(999, "Alpha")

		c := <-s.dispatch

		So(c.Args[0], ShouldEqual, "Alpha")
	})

    Convey("App should handle yields well", t, func() {
        s.Send(`["NewApp", 10, 11, 12345, 0, "xs.test"]`)
        <-s.dispatch

        a, _ := s.memory.Get(12345)
        app := a.(*app)

        app.CallbackSend(999, "Alpha")

        c := <-s.dispatch

        So(c.Args[0], ShouldEqual, "Alpha")
    })
}

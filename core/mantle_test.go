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
			So(len(s.memory), ShouldEqual, 2)

			_, ok := s.memory[12345]
			So(ok, ShouldBeTrue)
		})
	})
}

func TestCallbacks(t *testing.T) {
	s := NewSession()

	Convey("App callbacks should be bound to mantle dispatch", t, func() {
		s.Send(`["NewApp", 10, 11, 12345, 0, "xs.test"]`)
		<-s.dispatch

		app := s.memory[12345].(*app)
		app.CallbackSend(999, "Alpha")

		c := <-s.dispatch

		So(c.Args[0], ShouldEqual, "Alpha")
	})
}

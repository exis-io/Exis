package core

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestConcurrentBindingMap(t *testing.T) {
	Convey("Binding maps should accept bindings", t, func() {
		b := NewConcurrentBindingMap()

		a := &boundEndpoint{NewID(), "", nil}
		i := NewID()

		b.Set(i, a)

		c, _ := b.Get(i)
		So(c.callback, ShouldEqual, a.callback)
	})
}

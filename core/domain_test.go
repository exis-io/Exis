package core

import (
    "testing"

    . "github.com/smartystreets/goconvey/convey"
)

func TestDomainObjects(t *testing.T) {
	domain := NewDomain("xs.test", nil)

	Convey("Constructing a new domain object", t, func() {
		Convey("Should have an app object", func() {
			So(domain.GetApp(), ShouldNotBeNil)
		})
	})

	Convey("Calling Subdomain", t, func() {
		subdomain := domain.Subdomain("child")

		Convey("Should use the same app", func() {
			So(subdomain.GetApp(), ShouldEqual, domain.GetApp())
		})
	})

	Convey("Calling LinkDomain", t, func() {
		other := domain.LinkDomain("xs.other")

		Convey("Should use the same app", func() {
			So(other.GetApp(), ShouldEqual, domain.GetApp())
		})
	})
}

func TestDomainCallExpects(t *testing.T) {
	domain := NewDomain("xs.test", nil)

	Convey("Setting expected call response types", t, func() {
		id := NewID()
		types := []interface{}{"int"}

		domain.CallExpects(id, types)

		Convey("Should be retrievable", func() {
			_, ok := domain.GetCallExpect(id)
			So(ok, ShouldBeTrue)
		})

		Convey("Should be removable", func() {
			domain.RemoveCallExpect(id)
			_, ok := domain.GetCallExpect(id)
			So(ok, ShouldBeFalse)
		})
	})
}

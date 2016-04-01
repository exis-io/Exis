package core

import (
	"strings"
    "testing"

    . "github.com/smartystreets/goconvey/convey"
)

func TestFormatUnexpectedMessage(t *testing.T) {
	Convey("With ABORT message", t, func() {
		msg := new(abort)
		msg.Reason = "AOEU"

		s := formatUnexpectedMessage(msg, "WELCOME")

		Convey("Should format message with reason string", func() {
			So(strings.Contains(s, "AOEU"), ShouldBeTrue)
		})

		Convey("Should format message with type", func() {
			So(strings.Contains(s, "ABORT"), ShouldBeTrue)
		})
	})

	Convey("With GOODBYE message", t, func() {
		msg := new(goodbye)
		msg.Reason = "AOEU"

		s := formatUnexpectedMessage(msg, "WELCOME")

		Convey("Should format message with reason string", func() {
			So(strings.Contains(s, "AOEU"), ShouldBeTrue)
		})

		Convey("Should format message with type", func() {
			So(strings.Contains(s, "GOODBYE"), ShouldBeTrue)
		})
	})

	Convey("With other message", t, func() {
		msg := new(registered)

		s := formatUnexpectedMessage(msg, "WELCOME")

		Convey("Should format message with type", func() {
			So(strings.Contains(s, "REGISTERED"), ShouldBeTrue)
		})
	})
}

func TestRemoveDomain(t *testing.T) {
	Convey("Removing a domain", t, func() {
		d1 := &domain{}
		d2 := &domain{}
		d3 := &domain{}

		domains := []*domain{d1, d2}

		Convey("Should work for a domain in the list", func() {
			_, ok := removeDomain(domains, d1)
			So(ok, ShouldBeTrue)
		})

		Convey("Should not work for a domain not in the list", func() {
			_, ok := removeDomain(domains, d3)
			So(ok, ShouldBeFalse)
		})
	})
}

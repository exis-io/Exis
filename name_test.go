package coreRiffle

import (
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestValidDomain(t *testing.T) {
	Convey("Valid endpoints", t, func() {
		Convey("Don't need to have periods", func() {
			So(validEndpoint("pd"), ShouldBeTrue)
		})

		Convey("Can have a single subdomain", func() {
			So(validEndpoint("pd.damouse"), ShouldBeTrue)
		})

		Convey("Can have an arbitrary number of subdomains", func() {
			So(validEndpoint("pd.damouse.a.b.c"), ShouldBeTrue)
		})
	})

	Convey("Invalid endpoints", t, func() {
		Convey("Cannot end in an period", func() {
			So(validEndpoint("pd."), ShouldBeFalse)
		})

		Convey("Cannot end in an period and slash", func() {
			So(validEndpoint("pd./"), ShouldBeFalse)
		})

		Convey("Cannot end in an period, slash, and text", func() {
			So(validEndpoint("pd./a"), ShouldBeFalse)
		})
	})
}

func TestExtractDomain(t *testing.T) {
	Convey("Single domains can be extracted", t, func() {
		s, _ := extractDomain("pd.damouse/alpha")
		So(s, ShouldEqual, "pd.damouse")
	})
}

func TestExtractAction(t *testing.T) {
	Convey("Single actions can be extracted", t, func() {
		s, _ := extractActions("pd/alpha")
		So(s, ShouldEqual, "alpha")
	})
}

func TestExtractBoth(t *testing.T) {
	Convey("Valid endpoints", t, func() {
		Convey("With one domain can be extracted", func() {
			e, a, ok := breakdownEndpoint("pd/alpha")

			So(e, ShouldEqual, "pd")
			So(a, ShouldEqual, "alpha")
			So(ok, ShouldBeNil)
		})

		Convey("With a subdonmain can be extracted", func() {
			e, a, ok := breakdownEndpoint("pd.x/alpha")

			So(e, ShouldEqual, "pd.x")
			So(a, ShouldEqual, "alpha")
			So(ok, ShouldBeNil)
		})

		Convey("With a subaction can be extracted", func() {
			e, a, ok := breakdownEndpoint("pd.x/alpha/beta")

			So(e, ShouldEqual, "pd.x")
			So(a, ShouldEqual, "alpha/beta")
			So(ok, ShouldBeNil)
		})
	})

	Convey("Endpoints are considered invalid", t, func() {
		Convey("When blank", func() {
			_, _, ok := breakdownEndpoint("")

			So(ok, ShouldNotBeNil)
		})
	})
}

func TestDownwardAction(t *testing.T) {
	Convey("Valid subdomains", t, func() {
		Convey("Can be the same domain", func() {
			So(subdomain("pd.damouse", "pd.damouse"), ShouldBeTrue)
		})

		Convey("Can have one domain", func() {
			So(subdomain("pd.damouse", "pd.damouse.aardvark"), ShouldBeTrue)
		})

		Convey("Can have arbitrarily many subdomains", func() {
			So(subdomain("pd.damouse", "pd.damouse.a.b.c"), ShouldBeTrue)
		})
	})

	Convey("Invalid subdomains", t, func() {
		Convey("Can start with different letters", func() {
			So(subdomain("pd.xamouse", "pd.damouse"), ShouldBeFalse)
		})

		Convey("Can have intermediate domains", func() {
			So(subdomain("pd.damouse", "pd.aardvark.damouse"), ShouldBeFalse)
		})

		Convey("Can have spaces at the start", func() {
			So(subdomain(" pd.damouse", "pd.damouse.a.b.c"), ShouldBeFalse)
		})
	})
}

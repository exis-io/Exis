package core

import (
	"reflect"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
)

func TestValidDomain(t *testing.T) {
	Convey("Valid endpoints", t, func() {
		Convey("Don't need to have periods", func() {
			So(validDomain("pd"), ShouldBeTrue)
		})

		Convey("Can have a single subdomain", func() {
			So(validDomain("pd.damouse"), ShouldBeTrue)
		})

		Convey("Can have an arbitrary number of subdomains", func() {
			So(validDomain("pd.damouse.a.b.c"), ShouldBeTrue)
		})
	})

	Convey("Invalid endpoints", t, func() {
		Convey("Cannot end in an period", func() {
			So(validDomain("pd."), ShouldBeFalse)
		})

		Convey("Cannot end in an period and slash", func() {
			So(validDomain("pd./"), ShouldBeFalse)
		})

		Convey("Cannot end in an period, slash, and text", func() {
			So(validDomain("pd./a"), ShouldBeFalse)
		})
	})
}

func TestMakeEndpoint(t *testing.T) {
	Convey("Building an endpoint", t, func() {
		Convey("Can append an action", func() {
			s := makeEndpoint("xs.test", "action")
			So(s, ShouldEqual, "xs.test/action")
		})

		Convey("Accepts a full endpoint", func() {
			s := makeEndpoint("xs.test", "xs.other/action")
			So(s, ShouldEqual, "xs.other/action")
		})
	})
}

func TestExtractDomain(t *testing.T) {
	Convey("Single domains can be extracted", t, func() {
		s, _ := extractDomain("pd.damouse/alpha")
		So(s, ShouldEqual, "pd.damouse")
	})
}

func TestTopLevelDomain(t *testing.T) {
	Convey("Top level domain can be extracted", t, func() {
		s := topLevelDomain("xs.test/action")
		So(s, ShouldEqual, "xs")
	})
}

func TestAncestorDomains(t *testing.T) {
	Convey("Should work without appended string", t, func() {
		expected := []string{"xs.X", "xs"}
		results := ancestorDomains("xs.X.Y", "")
		So(reflect.DeepEqual(results, expected), ShouldBeTrue)
	})

	Convey("Should work with appended string", t, func() {
		expected := []string{"xs.X.Auth", "xs.Auth"}
		results := ancestorDomains("xs.X.Y.Auth", "Auth")
		So(reflect.DeepEqual(results, expected), ShouldBeTrue)
	})
}

func TestExtractAction(t *testing.T) {
	Convey("Single actions can be extracted", t, func() {
		s, _ := extractActions("pd/alpha")
		So(s, ShouldEqual, "alpha")
	})

	Convey("Invalid endpoints produce an error", t, func() {
		_, err := extractActions("xs.test")
		So(err, ShouldNotBeNil)
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

		Convey("With a short action can be extracted", func() {
			domain, action, ok := breakdownEndpoint("xs.test/a")
			So(domain, ShouldEqual, "xs.test")
			So(action, ShouldEqual, "a")
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

		Convey("Can be longer", func() {
			So(subdomain("xs.demo.lance", "xs.demo"), ShouldBeFalse)
		})
	})
}

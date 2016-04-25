package shared

import (
	"math/rand"
	"testing"
	"time"

	"github.com/exis-io/core"
	. "github.com/smartystreets/goconvey/convey"
)

// "Manually" here meaning the domain being used should be set up outside of this test
func TestAuthManually(t *testing.T) {
	core.SetSafeSSLOff()
	core.SetConnectionFactory(ConnectionFactory{})

	Convey("When the auth level is 0", t, func() {
		core.SetAuthenticationOn()

		app, username, password, email, name := "xs.demo.damouse.auth0test", "alpha", "12345678", "alpha@gmail.com", "alpha"
		a := core.NewApp(app)

		Convey("Register should always fail", func() {
			e := a.Register(username, password, email, name)
			So(e, ShouldNotBeNil)
			So(e.Error(), ShouldEqual, "Incorrect auth level")
		})

		Convey("Login should succeed when given a domain name", func() {
			n := randString(5)
			_, domain, e := a.Login([]interface{}{n})
			So(e, ShouldBeNil)
			So(domain, ShouldEqual, app+"."+n)
		})

		Convey("Join should suceed after a login", func() {
			c := core.NewApp(app)
			n := randString(5)

			_, _, e := c.Login([]interface{}{n})
			So(e, ShouldBeNil)

			e = c.Connect()
			So(e, ShouldBeNil)
		})

		Convey("Login should succeed with a random name if not given one", func() {
			_, domain, e := a.Login([]interface{}{})
			So(e, ShouldBeNil)
			So(a.GetAgent(), ShouldEqual, domain)
		})
	})

	Convey("When the auth level is 1", t, func() {
		app, password := "xs.demo.damouse.auth1test", randString(10)
		a := core.NewApp(app)

		Convey("Register should succeed", func() {
			email, name := randString(5)+"@gmail.com", randString(10)
			e := a.Register(name, password, email, name)
			So(e, ShouldBeNil)
		})

		Convey("Login should succeed after registering", func() {
			email, name := randString(5)+"@gmail.com", randString(10)
			e := a.Register(name, password, email, name)
			So(e, ShouldBeNil)

			_, _, err := a.Login([]interface{}{name, password})
			So(err, ShouldBeNil)
		})
	})

	Convey("When using a fabric that doesnt have authentication", t, func() {
		app, password, email, name := "xs.demo.damouse.auth3test", randString(10), randString(5)+"@gmail.com", randString(10)
		a := core.NewApp(app)
		core.SetAuthenticationOff()

		Convey("Login succeeds with a domain", func() {
			_, _, e := a.Login([]interface{}{name})
			So(e, ShouldBeNil)
		})

		Convey("Login fails when not given a domain", func() {
			_, _, e := a.Login([]interface{}{})
			So(e, ShouldNotBeNil)
		})

		Convey("Register should always succeed", func() {
			e := a.Register(name, password, email, name)
			So(e, ShouldBeNil)
		})

		core.SetAuthenticationOn()
	})
}

var letters = []rune("abcdefghijklmnopqrstuvwxyz")

func randString(n int) string {
	rand.Seed(time.Now().Unix())

	b := make([]rune, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}

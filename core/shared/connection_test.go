package shared

import (
	"math/rand"
	"testing"
	"time"

	"github.com/exis-io/core"
	. "github.com/smartystreets/goconvey/convey"
)

func TestDefaultConnection(t *testing.T) {
	Convey("Using the default connection factory", t, func() {
		core.SetConnectionFactory(ConnectionFactory{})
		core.SetFabricDev()
		a := core.NewApp("xs.test")

		Convey("Should connect successfully", func() {
			e := a.Connect()
			So(e, ShouldBeNil)
		})
	})
}

// "Manually" here meaning the domain being used should be set up outside of this test
func TestAuthManually(t *testing.T) {
	core.SetSafeSSLOff()
	core.SetConnectionFactory(ConnectionFactory{})

	// Convey("When the auth level is 0", t, func() {
	// 	app, username, password, email, name := "xs.demo.damouse.auth0test", "alpha", "12345678", "alpha@gmail.com", "alpha"
	// 	a := core.NewApp(app)

	// 	Convey("Register should always fail", func() {
	// 		e := a.Register(username, password, email, name)
	// 		So(e, ShouldNotBeNil)
	// 		So(e.Error(), ShouldEqual, "Incorrect auth level")
	// 	})

	// 	Convey("Login should succeed when given a domain name", func() {
	// 		n := randString(5)
	// 		_, domain, e := a.Login([]interface{}{n})
	// 		So(e, ShouldBeNil)
	// 		So(domain, ShouldEqual, app+"."+n)
	// 	})

	// 	Convey("Join should suceed after a login", func() {
	// 		c := core.NewApp(app)
	// 		n := randString(5)

	// 		_, _, e := c.Login([]interface{}{n})
	// 		So(e, ShouldBeNil)

	// 		e = c.Connect()
	// 		So(e, ShouldBeNil)
	// 	})

	// 	Convey("Login should succeed with a random name if not given one", func() {
	// 		_, domain, e := a.Login([]interface{}{})
	// 		So(e, ShouldBeNil)
	// 		So(a.GetAgent(), ShouldEqual, domain)
	// 	})
	// })

	// Convey("When the auth level is 1", t, func() {
	// 	app, password := "xs.demo.damouse.auth1test", randString(10)
	// 	a := core.NewApp(app)

	// 	Convey("Register should succeed", func() {
	// 		email, name := randString(5)+"@gmail.com", randString(10)
	// 		e := a.Register(name, password, email, name)
	// 		So(e, ShouldBeNil)
	// 	})

	// 	Convey("Login should succeed after registering", func() {
	// 		email, name := randString(5)+"@gmail.com", randString(10)
	// 		e := a.Register(name, password, email, name)
	// 		So(e, ShouldBeNil)

	// 		_, _, err := a.Login([]interface{}{name, password})
	// 		So(err, ShouldBeNil)
	// 	})
	// })

	Convey("When using a fabric that doesnt have authentication", t, func() {
		app, password := "xs.demo.damouse.auth3test", randString(10)
		a := core.NewApp(app)
		core.SetAuthenticationOff()

		Convey("Register should always suceed", func() {
			email, name := randString(5)+"@gmail.com", randString(10)
			e := a.Register(name, password, email, name)
			So(e, ShouldBeNil)
		})

		core.SetAuthenticationOn()
	})
}

func TestYields(t *testing.T) {
	Convey("App should handle yields well", t, func() {
		core.SetFabricDev()
		core.SetLogLevelDebug()

		// Convey("Should connect successfully manually", func() {
		//  a := core.NewApp("xs.a")
		//  b := core.NewApp("xs.a")

		//  a2 := a.NewDomain("b", 0, 0)
		//  b1 := b.NewDomain("b", 0, 0)

		//  a.Join()
		//  b.Join()

		//  b1.Register("fun", 1, []interface{}{"int"}, make(map[string]interface{}))

		//  a2.Call("fun", []interface{}{1}, make(map[string]interface{}))
		// })

		// Convey("Should connect successfully through the mantle", func() {
		//  s := core.NewSession()

		//  s.Send(`["NewApp", 10, 11, 11, 0, "xs.a"]`)
		//  s.Send(`["NewApp", 10, 11, 12, 0, "xs.a"]`)

		//  s.Send(`["NewDomain", 10, 11, 13, 12, "a", 13, 14]`)
		//  s.Send(`["NewDomain", 10, 11, 14, 11, "a", 14, 15]`)

		//  s.Send(`["Join", 10, 11, 0, 11]`)
		//  s.Send(`["Join", 10, 11, 0, 12]`)

		//  s.Send(`["Register", 10, 11, 0, 13, "fun", 16, ["int"], {}]`)

		//  fmt.Println("Making the call")
		//  go s.Send(`["Call", 10, 11, 0, 14, "fun", [1], {}]`)
		//  fmt.Println("Starting the return")

		//  time.Sleep(30 * time.Millisecond)

		//  s.Send(`["Yield", 10, 11, 0, 12, 10, [1]]`)

		//  for {
		//      d := <-s.Receive()
		//      core.Debug("%v", d)
		//  }
		// })
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

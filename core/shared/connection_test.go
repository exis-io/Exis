package shared

import (
	"testing"

	"github.com/exis-io/core"
	. "github.com/smartystreets/goconvey/convey"
)

func TestDefaultConnection(t *testing.T) {
	Convey("Using the default connection factory", t, func() {
		// DefaultConnectionFactory = stubConnection{}
		core.SetConnectionFactory(ConnectionFactory{})
		core.SetFabricDev()
		core.SetLogLevelDebug()
		a := core.NewApp("xs.test")

		Convey("Should connect successfully", func() {
			e := a.Join()
			So(e, ShouldBeNil)
		})
	})
}

func TestYields(t *testing.T) {
	Convey("App should handle yields well", t, func() {
		core.SetFabricDev()
		core.SetLogLevelDebug()

		// Convey("Should connect successfully manually", func() {
		// 	a := core.NewApp("xs.a")
		// 	b := core.NewApp("xs.a")

		// 	a2 := a.NewDomain("b", 0, 0)
		// 	b1 := b.NewDomain("b", 0, 0)

		// 	a.Join()
		// 	b.Join()

		// 	b1.Register("fun", 1, []interface{}{"int"}, make(map[string]interface{}))

		// 	a2.Call("fun", []interface{}{1}, make(map[string]interface{}))
		// })

		// Convey("Should connect successfully through the mantle", func() {
		// 	s := core.NewSession()

		// 	s.Send(`["NewApp", 10, 11, 11, 0, "xs.a"]`)
		// 	s.Send(`["NewApp", 10, 11, 12, 0, "xs.a"]`)

		// 	s.Send(`["NewDomain", 10, 11, 13, 12, "a", 13, 14]`)
		// 	s.Send(`["NewDomain", 10, 11, 14, 11, "a", 14, 15]`)

		// 	s.Send(`["Join", 10, 11, 0, 11]`)
		// 	s.Send(`["Join", 10, 11, 0, 12]`)

		// 	s.Send(`["Register", 10, 11, 0, 13, "fun", 16, ["int"], {}]`)

		// 	fmt.Println("Making the call")
		// 	go s.Send(`["Call", 10, 11, 0, 14, "fun", [1], {}]`)
		// 	fmt.Println("Starting the return")

		// 	for {
		// 		d := <-s.Receive()
		// 		core.Debug("%v", d)
		// 	}
		// })
	})
}

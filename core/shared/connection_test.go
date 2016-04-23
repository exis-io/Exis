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

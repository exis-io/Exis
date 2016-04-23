package main

import (
    "testing"
    "github.com/exis-io/core"
        "github.com/exis-io/core/shared"

    . "github.com/smartystreets/goconvey/convey"
)

func TestConnection(t *testing.T) {
    s := core.NewSession()
    core.SetFabricDev()
    core.SetLogLevelDebug()
    core.SetConnectionFactory(shared.ConnectionFactory{})

    Convey("Mantle connections should succeed", t, func() {
        s.Send(`["NewApp", 10, 11, 12345, 0, "xs.test"]`)
        <- s.Receive()
        s.Send(`["Join", 10, 11, 0, 12345]`)
        r := <- s.Receive()

        So(r, ShouldBeNil)    
    })
}

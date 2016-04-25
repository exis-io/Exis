package shared

import (
	"testing"

	"github.com/exis-io/core"
	. "github.com/smartystreets/goconvey/convey"
)

func TestBasicModelOperations(t *testing.T) {
	core.SetConnectionFactory(ConnectionFactory{})
	core.SetSafeSSLOff()

	a := core.NewApp("xs.demo.damouse.model")
	a.Login([]interface{}{})
	a.Connect()
	m, _ := a.InitModels()

	name := randString(6)
	i1, i2 := core.NewID(), core.NewID()
	j1 := map[string]interface{}{"name": "steve", "age": 14, "_xsid": i1}
	j2 := map[string]interface{}{"name": "bob", "age": 96, "_xsid": i2}

	m.Create(name, j1)
	m.Create(name, j2)

	Convey("Single model objects", t, func() {
		Convey("Increases reported count after creation ", func() {
			r, e := m.Count(name)
			So(e, ShouldBeNil)
			So(r, ShouldEqual, 2)
		})

		Convey("Appear when loading all models", func() {
			r, e := m.All(name)
			So(e, ShouldBeNil)
			So(len(r), ShouldEqual, 2)
		})

		Convey("Can be found", func() {
			r, e := m.Find(name, map[string]interface{}{"name": "steve"})
			So(e, ShouldBeNil)
			So(len(r), ShouldEqual, 1)
		})

		Convey("Can be updated", func() {
			e := m.Save(name, map[string]interface{}{"name": "steve", "age": 99, "_xsid": i1})
			So(e, ShouldBeNil)

			r, _ := m.Find(name, map[string]interface{}{"_xsid": i1})
			So(len(r), ShouldEqual, 1)
			So(r[0]["age"], ShouldEqual, 99)

			c, _ := m.Count(name)
			So(c, ShouldEqual, 2)
		})

		Convey("Can be destroyed", func() {
			So(m.Destroy(name, i1), ShouldBeNil)

			c, _ := m.Count(name)
			So(c, ShouldEqual, 1)

			m.Destroy(name, i2)
			c2, _ := m.Count(name)
			So(c2, ShouldEqual, 0)
		})
	})
}

func TestModelCollectionOperations(t *testing.T) {
	core.SetConnectionFactory(ConnectionFactory{})
	core.SetSafeSSLOff()

	a := core.NewApp("xs.demo.damouse.model")
	a.Login([]interface{}{})
	a.Connect()
	m, _ := a.InitModels()

	name := randString(6)
	i1, i2 := core.NewID(), core.NewID()
	j1 := map[string]interface{}{"name": "steve", "age": 14, "_xsid": i1}
	j2 := map[string]interface{}{"name": "bob", "age": 96, "_xsid": i2}

	m.CreateMany(name, []map[string]interface{}{j1, j2})

	Convey("Collections of model objects", t, func() {
		Convey("Can be created as a list", func() {
			c, _ := m.Count(name)
			So(c, ShouldEqual, 2)
		})

		Convey("Can be updated as a list", func() {
			j1["age"] = 99
			j2["age"] = 88

			e := m.SaveMany(name, []map[string]interface{}{j1, j2})
			So(e, ShouldBeNil)

			c, _ := m.Count(name)
			So(c, ShouldEqual, 2)

			all, _ := m.All(name)
			So(len(all), ShouldEqual, 2)

			f, e := m.Find(name, map[string]interface{}{"_xsid": i1})
			So(e, ShouldBeNil)
			So(len(f), ShouldEqual, 1)
			So(f[0]["age"], ShouldEqual, 99)
		})

		Convey("Can all be destroyed at once", func() {
			So(m.DestroyMany(name, []uint64{i1, i2}), ShouldBeNil)

			c, _ := m.Count(name)
			So(c, ShouldEqual, 0)
		})
	})
}

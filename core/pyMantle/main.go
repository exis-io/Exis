package riffle

import (
	"github.com/exis-io/core"
	"github.com/exis-io/core/goRiffle"
)

var fabric string = core.FabricProduction

type Domain struct {
	coreDomain core.Domain
}

func NewDomain(name string) Domain {
	return Domain{
		coreDomain: core.NewDomain(name, nil),
	}
}

func (d *Domain) Subdomain(name string) Domain {
	return d.Subdomain(name)
}

// Blocks on callbacks from the core.
// TODO: trigger a close meta callback when connection is lost
func (d *Domain) Receive() string {
	return core.MantleMarshall(d.coreDomain.GetApp().CallbackListen())
}

func (d *Domain) Join(cb uint, eb uint) {
	if c, err := goRiffle.Open(fabric); err != nil {
		d.coreDomain.GetApp().CallbackSend(eb, err.Error())
	} else {
		if err := d.coreDomain.Join(c); err != nil {
			d.coreDomain.GetApp().CallbackSend(eb, err.Error())
		} else {
			d.coreDomain.GetApp().CallbackSend(cb)
		}
	}
}

func (d Domain) Subscribe(cb uint, endpoint string) {
	go func() {
		d.coreDomain.Subscribe(endpoint, cb, make([]interface{}, 0))
	}()
}

func (d Domain) Register(cb uint, endpoint string) {
	go func() {
		d.coreDomain.Register(endpoint, cb, make([]interface{}, 0))
	}()
}

// Args are string encoded json
func (d Domain) Publish(cb uint, endpoint string, args string) {
	go func() {
		d.coreDomain.Publish(endpoint, cb, core.MantleUnmarshal(args))
	}()
}

func (d Domain) Call(cb uint, endpoint string, args string) {
	go func() {
		d.coreDomain.Call(endpoint, cb, core.MantleUnmarshal(args))
	}()
}

func (d Domain) Yield(request uint, args string) {
	go func() {
		d.coreDomain.GetApp().Yield(request, core.MantleUnmarshal(args))
	}()
}

func (d Domain) Unsubscribe(endpoint string) {
	go func() {
		d.coreDomain.Unsubscribe(endpoint)
	}()
}

func (d Domain) Unregister(endpoint string) {
	go func() {
		d.coreDomain.Unregister(endpoint)
	}()
}

func (d Domain) Leave() {
	go func() {
		d.coreDomain.Leave()
	}()
}

func SetLogLevelOff()   { core.LogLevel = core.LogLevelOff }
func SetLogLevelApp()   { core.LogLevel = core.LogLevelApp }
func SetLogLevelErr()   { core.LogLevel = core.LogLevelErr }
func SetLogLevelWarn()  { core.LogLevel = core.LogLevelWarn }
func SetLogLevelInfo()  { core.LogLevel = core.LogLevelInfo }
func SetLogLevelDebug() { core.LogLevel = core.LogLevelDebug }

func SetFabricDev()        { fabric = core.FabricDev }
func SetFabricSandbox()    { fabric = core.FabricSandbox }
func SetFabricProduction() { fabric = core.FabricProduction }
func SetFabricLocal()      { fabric = core.FabricLocal }
func SetFabric(url string) { fabric = url }

func Application(s string) { core.Application("%s", s) }
func Debug(s string)       { core.Debug("%s", s) }
func Info(s string)        { core.Info("%s", s) }
func Warn(s string)        { core.Warn("%s", s) }
func Error(s string)       { core.Error("%s", s) }

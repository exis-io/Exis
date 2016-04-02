package pymantle

import (
	"github.com/exis-io/core"
	"github.com/exis-io/core/shared"
)

type Domain struct {
	coreDomain core.Domain
}

func NewDomain(name string) Domain {
	return Domain{coreDomain: core.NewDomain(name, nil)}
}

func (d *Domain) Subdomain(name string) Domain {
	return Domain{coreDomain: d.coreDomain.Subdomain(name)}
}

func (d *Domain) LinkDomain(name string) Domain {
	return Domain{coreDomain: d.coreDomain.LinkDomain(name)}
}

// Blocks on callbacks from the core
func (d *Domain) Receive() string {
	return core.MantleMarshall(d.coreDomain.GetApp().CallbackListen())
}

// TODO: Move this to the mantle helper
func (d *Domain) Join(cb uint64, eb uint64) {
	if c, err := shared.Open(core.Fabric); err != nil {
		d.coreDomain.GetApp().CallbackSend(eb, err.Error())
	} else {
		if err := d.coreDomain.Join(c); err != nil {
			d.coreDomain.GetApp().CallbackSend(eb, err.Error())
		} else {
			d.coreDomain.GetApp().CallbackSend(cb)
		}
	}
}

func (d *Domain) Subscribe(endpoint string, cb uint64, eb uint64, fn uint64, types string) {
	go core.MantleSubscribe(d.coreDomain, endpoint, cb, eb, fn, core.MantleUnmarshal(types))
}

func (d *Domain) Register(endpoint string, cb uint64, eb uint64, fn uint64, types string) {
	go core.MantleRegister(d.coreDomain, endpoint, cb, eb, fn, core.MantleUnmarshal(types))
}

func (d *Domain) Publish(endpoint string, cb uint64, eb uint64, args string) {
	go core.MantlePublish(d.coreDomain, endpoint, cb, eb, core.MantleUnmarshal(args))
}

func (d *Domain) Call(endpoint string, cb uint64, eb uint64, args string) {
	go core.MantleCall(d.coreDomain, endpoint, cb, eb, core.MantleUnmarshal(args))
}

func (d *Domain) CallExpects(cb uint64, types string) {
	go d.coreDomain.CallExpects(cb, core.MantleUnmarshal(types))
}

func (d *Domain) Unsubscribe(endpoint string, cb uint64, eb uint64) {
	go core.MantleUnsubscribe(d.coreDomain, endpoint, cb, eb)
}

func (d *Domain) Unregister(endpoint string, cb uint64, eb uint64) {
	go core.MantleUnregister(d.coreDomain, endpoint, cb, eb)
}

func (d *Domain) Yield(request uint64, args string) {
	go d.coreDomain.GetApp().Yield(request, core.MantleUnmarshal(args))
}

func (d *Domain) YieldError(request uint64, etype string, args string) {
	go d.coreDomain.GetApp().YieldError(request, etype, core.MantleUnmarshal(args))
}

func (d *Domain) SetToken(token string) {
	app := d.coreDomain.GetApp()
	app.SetToken(token)
}

func (d *Domain) Leave() {
	go d.coreDomain.Leave()
}

func SetLogLevelOff()   { core.LogLevel = core.LogLevelOff }
func SetLogLevelApp()   { core.LogLevel = core.LogLevelApp }
func SetLogLevelErr()   { core.LogLevel = core.LogLevelErr }
func SetLogLevelWarn()  { core.LogLevel = core.LogLevelWarn }
func SetLogLevelInfo()  { core.LogLevel = core.LogLevelInfo }
func SetLogLevelDebug() { core.LogLevel = core.LogLevelDebug }

func SetFabricDev() {
	core.Fabric = core.FabricDev
	core.Registrar = core.RegistrarDev
}
func SetFabricSandbox() { core.Fabric = core.FabricSandbox }
func SetFabricProduction() {
	core.Fabric = core.FabricProduction
	core.Registrar = core.RegistrarProduction
}
func SetFabricLocal() {
	core.Fabric = core.FabricLocal
	core.Registrar = core.RegistrarLocal
}
func SetFabric(url string)    { core.Fabric = url }
func SetRegistrar(url string) { core.Registrar = url }

func Application(s string) { core.Application("%s", s) }
func Debug(s string)       { core.Debug("%s", s) }
func Info(s string)        { core.Info("%s", s) }
func Warn(s string)        { core.Warn("%s", s) }
func Error(s string)       { core.Error("%s", s) }

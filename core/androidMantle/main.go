package mantle

import (
	"encoding/json"

	"github.com/exis-io/core"
	"github.com/exis-io/core/shared"
)

type Domain struct {
	coreDomain core.Domain
}

func NewDomain(name string) *Domain {
	core.UseUnsafeCert = true
	return &Domain{coreDomain: core.NewDomain(name, nil)}
}

func (d *Domain) Subdomain(name string) *Domain {
	return &Domain{coreDomain: d.coreDomain.Subdomain(name)}
}

func (d *Domain) LinkDomain(name string) *Domain {
	return &Domain{coreDomain: d.coreDomain.LinkDomain(name)}
}

func (d *Domain) Receive() string {
	return core.MantleMarshall(d.coreDomain.GetApp().CallbackListen())
}

func (d *Domain) Join(cb string, eb string) {
	go func() {
		if c, err := shared.Open(core.Fabric); err != nil {
			d.coreDomain.GetApp().CallbackSend(idUnmarshal(eb), err.Error())
		} else {
			if err := d.coreDomain.Join(c); err != nil {
				// core.Warn("Mantle join failure: %v", err.Error())
				d.coreDomain.GetApp().CallbackSend(idUnmarshal(eb), err.Error())
			} else {
				// core.Warn("Mantle join success! %v", cb)
				d.coreDomain.GetApp().CallbackSend(idUnmarshal(cb))
			}
		}
	}()
}

// Called on the app domain, remember-- not the current domain
func (d *Domain) MentleLoginDomain(cb string, eb string, username string, password string) {
	args := []string{username}

	if password != "" {
		args = append(args, password)
	}

	core.Info("Arguments for the thing and domain: %v, %d", args, d)

	go func() {
		if ret, err := d.coreDomain.GetApp().Login(d.coreDomain, args...); err != nil {
			core.Warn("Unable to complete login %s", err.Error())
			d.coreDomain.GetApp().CallbackSend(idUnmarshal(eb), err.Error())
		} else {
			core.Info("Successfully logged in as %s", ret.GetName())
			core.Info("Joining on %s", d.coreDomain.GetName())

			if c, err := shared.Open(core.Fabric); err != nil {
				d.coreDomain.GetApp().CallbackSend(idUnmarshal(eb), err.Error())
			} else {
				if err := ret.Join(c); err != nil {
					d.coreDomain.GetApp().CallbackSend(idUnmarshal(eb), err.Error())
				} else {
					d.coreDomain.GetApp().CallbackSend(idUnmarshal(cb), ret.GetApp().GetToken())
				}
			}
		}
	}()
}

func (d *Domain) MentleRegisterDomain(cb string, eb string, username string, password string, email string, name string) {
	go func() {
		if _, err := d.coreDomain.GetApp().RegisterAccount(d.coreDomain, username, password, email, name); err != nil {
			core.Warn("Unable to complete login %s", err.Error())
			d.coreDomain.GetApp().CallbackSend(idUnmarshal(eb), err.Error())
		} else {
			core.Info("Successfully registered under account %s", username)
			d.MentleLoginDomain(cb, eb, username, password)
		}
	}()
}

func (d *Domain) Subscribe(endpoint string, cb string, eb string, fn string, types string) {
	go core.MantleSubscribe(d.coreDomain, endpoint, idUnmarshal(cb), idUnmarshal(eb), idUnmarshal(fn), core.MantleUnmarshal(types))
}

func (d *Domain) Register(endpoint string, cb string, eb string, fn string, types string) {
	go core.MantleRegister(d.coreDomain, endpoint, idUnmarshal(cb), idUnmarshal(eb), idUnmarshal(fn), core.MantleUnmarshal(types))
}

func (d *Domain) Publish(endpoint string, cb string, eb string, args string) {
	go core.MantlePublish(d.coreDomain, endpoint, idUnmarshal(cb), idUnmarshal(eb), core.MantleUnmarshal(args))
}

func (d *Domain) Call(endpoint string, cb string, eb string, args string) {
	go core.MantleCall(d.coreDomain, endpoint, idUnmarshal(cb), idUnmarshal(eb), core.MantleUnmarshal(args))
}

func (d *Domain) CallExpects(cb string, types string) {
	go d.coreDomain.CallExpects(idUnmarshal(cb), core.MantleUnmarshal(types))
}

func (d *Domain) Unsubscribe(endpoint string, cb string, eb string) {
	go core.MantleUnsubscribe(d.coreDomain, endpoint, idUnmarshal(cb), idUnmarshal(eb))
}

func (d *Domain) Unregister(endpoint string, cb string, eb string) {
	go core.MantleUnregister(d.coreDomain, endpoint, idUnmarshal(cb), idUnmarshal(eb))
}

func (d *Domain) Yield(request string, args string) {
	go d.coreDomain.GetApp().Yield(idUnmarshal(request), core.MantleUnmarshal(args))
}

func (d *Domain) YieldError(request string, etype string, args string) {
	go d.coreDomain.GetApp().YieldError(idUnmarshal(request), etype, core.MantleUnmarshal(args))
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

func SetCuminStrict() { core.CuminLevel = core.CuminStrict }
func SetCuminLoose()  { core.CuminLevel = core.CuminLoose }
func SetCuminOff()    { core.CuminLevel = core.CuminOff }

func Application(s string) { core.Application("%s", s) }
func Debug(s string)       { core.Debug("%s", s) }
func Info(s string)        { core.Info("%s", s) }
func Warn(s string)        { core.Warn("%s", s) }
func Error(s string)       { core.Error("%s", s) }

func idUnmarshal(a string) uint64 {
	var d uint64
	if e := json.Unmarshal([]byte(a), &d); e == nil {
		return d
	} else {
		core.Warn("Unable to unmarshall id: %s", e)
		return 0
	}
}

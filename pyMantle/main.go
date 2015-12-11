package riffle

import (
	"github.com/exis-io/core"
	"github.com/exis-io/core/goRiffle"
)

var fabric string = core.ProudctionFabric

type App struct {
	coreApp core.App
}

type Domain struct {
	app        *App
	coreDomain core.Domain
}

func (a *App) Init() {
	a.coreApp = core.NewApp()
}

func (a *App) NewDomain(name string) Domain {
	return Domain{
		app:        a,
		coreDomain: a.coreApp.NewDomain(name),
	}
}

// Blocks on callbacks from the core. TODO: trigger a close meta callback when connection is lost
func (a *App) Receive() string {
	return core.MantleMarshall(a.coreApp.CallbackListen())
}

func (d *Domain) Join(cb uint, eb uint) {
	if c, err := goRiffle.Open(fabric); err != nil {
		d.app.coreApp.CallbackSend(eb, err.Error())
	} else {
		c.App = d.app.coreApp

		if err := d.coreDomain.Join(c); err != nil {
			d.app.coreApp.CallbackSend(eb, err.Error())
		} else {
			d.app.coreApp.CallbackSend(cb)
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

func (a *App) Yield(request uint, args string) {
	go func() {
		a.coreApp.Yield(request, core.MantleUnmarshal(args))
	}()
}

func (d Domain) Unsubscribe(endpoint string) {

}

func (d Domain) Unregister(endpoint string) {

}

func (d Domain) Leave() {

}

func SetLogLevelApp()       { core.LogLevel = core.LogLevelApp }
func SetLogLevelErr()       { core.LogLevel = core.LogLevelErr }
func SetLogLevelWarn()      { core.LogLevel = core.LogLevelWarn }
func SetLogLevelInfo()      { core.LogLevel = core.LogLevelInfo }
func SetLogLevelDebug()     { core.LogLevel = core.LogLevelDebug }
func SetLoggingLevel(l int) { core.LogLevel = l }

func SetDevFabric()              { fabric = core.DevFabric }
func SetSandboxFabric()          { fabric = core.SandboxFabric }
func SetProductionFabric()       { fabric = core.ProudctionFabric }
func SetLocalFabric()            { fabric = core.LocalFabric }
func SetCustomFabric(url string) { fabric = url }

func Application(s string) { core.Application("%s", s) }
func Debug(s string)       { core.Debug("%s", s) }
func Info(s string)        { core.Info("%s", s) }
func Warn(s string)        { core.Warn("%s", s) }
func Error(s string)       { core.Error("%s", s) }

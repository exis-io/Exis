package riffle

import (
	"github.com/exis-io/core"
	"github.com/exis-io/core/goRiffle"
)

func main() {}

// type Domaine interface {
// 	Subscribe(string) (int, int)
// 	// Register(string, uint, []interface{}) error

// 	// Publish(string, uint, []interface{}) error
// 	// Call(string, uint, []interface{}) ([]interface{}, error)

// 	// Yield(uint, []interface{})

// 	// Unsubscribe(string) error
// 	// Unregister(string) error

// 	Join() (uint, uint)
// 	// Leave() error
// }

type AppIface interface {
	Init()
	NewDomain(string) Domain
	Receive() string
}

type DomainIface interface {
	Join()
}

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
	d := Domain{
		app:        a,
		coreDomain: a.coreApp.NewDomain(name),
	}

	return d
}

func (a *App) Receive() string {
	a.coreApp.CallbackListen()
	return "Message!"
}

func (d *Domain) Join() {
	if c, err := goRiffle.Open(core.LocalFabric); err != nil {
		// man.InvokeError(eb, err.Error())
		core.Warn("Unable to open connection: %s", err.Error())
	} else {
		c.App = d.app.coreApp

		if err := d.coreDomain.Join(c); err != nil {
			core.Warn("Unable to join! %s", err)
			// man.InvokeError(eb, err.Error())
		} else {
			core.Info("Joined!")
			// man.Invoke(cb, nil)
		}
	}
}

// func (d Domain) Subscribe(endpoint string) (int, int) {
// 	return 0, 0
// }

// Applys a set of parameters to the core domain using the passed function
// func domainCall(operation func(), endpoint string, args []interface{}) (uint, uint) {
// 	d := *(*core.Domain)(pdomain)
// 	cb, eb := core.NewID(), core.NewID()

// 	go func() {
// 		d.Subscribe(endpoint), cb, make([]interface{}, 0))
// 	}()

// 	return marshall([]uint{cb, eb})
// }

/*
//export Register
func Register(endpoint string) []byte {
	d := *(*core.Domain)(pdomain)
	cb, eb := core.NewID(), core.NewID()

	go func() {
		d.Register(endpoint), cb, make([]interface{}, 0))
	}()

	return marshall([]uint{cb, eb})
}

func Yield(args []byte) {
	// This needs work
	// core.Yield(e))
}

func Publish(endpoint string) {
	d := *(*core.Domain)(pdomain)
	cb, _ := core.NewID(), core.NewID()

	go func() {
		d.Publish(endpoint), cb, make([]interface{}, 0))
	}()
}

func Call(endpoint string) {
	d := *(*core.Domain)(pdomain)
	cb, _ := core.NewID(), core.NewID()

	go func() {
		d.Call(endpoint), cb, make([]interface{}, 0))
	}()
}

func Unsubscribe(pdomain unsafe.Pointer, e string) {
	d := *(*core.Domain)(pdomain)
	d.Unsubscribe(e))
}

func Unregister(pdomain unsafe.Pointer, e string) {
	d := *(*core.Domain)(pdomain)
	d.Unregister(e))
}


//export Leave
func Leave(pdomain unsafe.Pointer) {
	d := *(*core.Domain)(pdomain)
	d.Leave()
}

//export Recieve
func Recieve() []byte {
	data := <-man.recv
	return data
}

func marshall(data interface{}) []byte {
	if r, e := json.Marshal(data); e == nil {
		return r
	} else {
		fmt.Println("Unable to marshall data!")
		return nil
	}
}

func unmarshall() {

}
*/

// Unexported Functions
// func (m *App) invoke(id uint, args []interface{}) {
// core.Debug("Invoke called: ", id, args)
// man.recv <- marshall(map[string]interface{}{"0": id, "1": args})
// m.recv <- marshall([]interface{}{id, args})
// }

// func (m *App) InvokeError(id uint, e string) {
// core.Debug("Invoking error: ", id, e)
// s := fmt.Sprintf("Err: %s", e)
// m.recv <- marshall([]interface{}{id, s})
// }

func SetLoggingLevel(l int) {
	core.LogLevel = l
}

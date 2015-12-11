package riffle

import (
	"fmt"

	"github.com/exis-io/core"
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

// type AppIface interface {
// 	NewDomain(string) Domain
// }

// type App struct {
// 	coreApp core.App
// 	conn    *goRiffle.WebsocketConnection
// }

// type Domain struct {
// 	*App
// 	core core.Domain
// }

// func (a *App) NewDomain(name string) Domain {
// 	if a.coreApp == nil {
// 		a.coreApp = core.NewApp()
// 	}

// 	d := Domain{
// 		App:  a,
// 		core: a.coreApp.NewDomain(name),
// 	}

// 	return d
// }

// Exmaple
// Iface has a single F() method
type AppIface interface {
	NewDomain()
}

type DomainIface interface {
	Join()
}

// T implements Iface
type App struct{}
type Domain struct{}

func (t *App) NewDomain() Domain {
	fmt.Printf("App.NewDomain\n")
	return Domain{}
}

func (t *Domain) Join() {
	fmt.Printf("Domain.Join\n")
}

// func (d *Domain) Join() int {

// 	if d.App.conn != nil {
// 		// man.InvokeError(eb, "Connection is already open!")
// 		core.Warn("Connection is already open!")
// 	}

// 	if c, err := goRiffle.Open(core.DevFabric); err != nil {
// 		// man.InvokeError(eb, err.Error())
// 		core.Warn("Unable to open connection: %s", err.Error())
// 	} else {
// 		d.App.conn = c
// 		c.App = d.App.app

// 		if err := d.core.Join(c); err != nil {
// 			core.Warn("Unable to join! %s", err)
// 			// man.InvokeError(eb, err.Error())
// 		} else {
// 			core.Info("Joined!")
// 			// man.Invoke(cb, nil)
// 		}
// 	}

// 	return 0
// }

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

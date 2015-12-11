package riffle

import (
	"fmt"

	"github.com/exis-io/core"
	"github.com/exis-io/core/goRiffle"
)

type Domain interface {
	Subscribe(string) (int, int)
	// Register(string, uint, []interface{}) error

	// Publish(string, uint, []interface{}) error
	// Call(string, uint, []interface{}) ([]interface{}, error)

	// Yield(uint, []interface{})

	// Unsubscribe(string) error
	// Unregister(string) error

	// Join(Connection) error
	// Leave() error
}

type App struct {
	app  core.App
	conn *goRiffle.WebsocketConnection
	recv chan []byte
}

type domain struct {
	core core.Domain
}

// var man = &Mantle{
// 	recv: make(chan []byte),
// }

func main() {}

func (m *App) NewDomain(name string) Domain {
	fmt.Println("NewDomain called!")

	if m.app == nil {
		m.app = core.NewApp()
	}

	d := domain{
		core: m.app.NewDomain(name, m),
	}

	return d
}

// Applys a set of parameters to the core domain using the passed function
// func domainCall(operation func(), endpoint string, args []interface{}) (uint, uint) {
// 	d := *(*core.Domain)(pdomain)
// 	cb, eb := core.NewID(), core.NewID()

// 	go func() {
// 		d.Subscribe(endpoint), cb, make([]interface{}, 0))
// 	}()

// 	return marshall([]uint{cb, eb})
// }

func (d domain) Subscribe(endpoint string) (int, int) {
	return 0, 0
}

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

//export Join
func Join(pdomain unsafe.Pointer) []byte {
	d := *(*core.Domain)(pdomain)
	cb, eb := core.NewID(), core.NewID()

	go func() {
		if man.conn != nil {
			man.InvokeError(eb, "Connection is already open!")
		}

		if c, err := goRiffle.Open(core.DevFabric); err != nil {
			man.InvokeError(eb, err.Error())
		} else {
			man.conn = c
			c.App = man.app

			if err := d.Join(c); err != nil {
				core.Warn("Unable to join! %s", err)
				man.InvokeError(eb, err.Error())
			} else {
				core.Info("Joined!")
				man.Invoke(cb, nil)
			}
		}
	}()

	return marshall([]uint{cb, eb})
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

//export SetLoggingLevel
func SetLoggingLevel(l int) {
	core.LogLevel = l
}

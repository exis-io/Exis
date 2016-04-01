package goRiffle

import "github.com/exis-io/core"

// A wrapper around the core domain. Re-exposes the methods from the core

type Domain interface {
	Subdomain(string) Domain

	Subscribe(string, interface{}) error
	// Register(string, interface{}) error
	Publish(string, ...interface{}) error
	// Call(string, []interface{}) ([]interface{}, error)

	// Unsubscribe(string) error
	// Unregister(string) error

	Join() error
	// Leave() error
	Listen() error
}

type app struct {
	registrations map[uint64]interface{}
	subscriptions map[uint64]interface{}
	closing       chan bool // set when the connection closes
	coreApp       core.App
}

type domain struct {
	coreDomain core.Domain
	mantleApp  *app
}

func NewDomain(name string) Domain {
	core.CuminLevel = core.CuminOff

	a := app{
		registrations: make(map[uint64]interface{}),
		subscriptions: make(map[uint64]interface{}),
		closing:       make(chan bool, 1),
	}

	d := domain{core.NewDomain(name, nil), &a}
	a.coreApp = d.coreDomain.GetApp()

	return d

}

func (d domain) Subdomain(name string) Domain {
	return domain{d.coreDomain.Subdomain(name), d.mantleApp}
}

func (d domain) Join() error {
	if c, err := Open(core.Fabric); err != nil {
		return err
	} else if err := d.coreDomain.Join(c); err != nil {
		return err
	} else {
		go d.mantleApp.run()
		return nil
	}
}

// Main run loop. Start listening to the core. Run in a goroutine.
func (a *app) run() {
	for {
		cb := a.coreApp.CallbackListen()

		// 0 means close
		if cb.Id == 0 {
			Debug("Closing mantle receive loop")
			a.closing <- true
			break
		}

		// if handler, ok := a.subscriptions[id]; !ok {
		// 	Warn("No subscription found for id %s", cb.Id)
		// } else {

		// }
	}
}

// Block and listen until the connection closes
func (d domain) Listen() error {
	// TODO: return error if connetion has not been opened
	<-d.mantleApp.closing
	return nil
}

func (d domain) Subscribe(endpoint string, handler interface{}) error {
	c := core.NewID()
	if err := d.coreDomain.Subscribe(endpoint, c, nil); err != nil {
		return err
	} else {
		d.mantleApp.subscriptions[c] = handler
		return nil
	}
}

// func (d Domain) Register(endpoint string, handler interface{}) error {
// 	return d.coreDomain.Register()
// }

func (d domain) Publish(endpoint string, args ...interface{}) error {
	return d.coreDomain.Publish(endpoint, args)
}

// func (d Domain) Call(endpoint string, args []interface{}) ([]interface{}, error) {
// 	return d.coreDomain.Call()
// }

// func (d Domain) Unsubscribe(string) error {
// 	return d.coreDomain.Unsubscribe()
// }

// func (d Domain) Unregister(string) error {
// 	return d.coreDomain.Unregister()
// }

// func (d Domain) Leave() error {
// 	return d.coreDomain.Leave()
// }

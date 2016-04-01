package goRiffle

import "github.com/exis-io/core"

// A wrapper around the core domain. Re-exposes the methods from the core

type Domain interface {
	Subdomain(string) Domain

	Subscribe(string, interface{}) error
	Register(string, interface{}) error
	Publish(string, ...interface{}) error
	Call(string, ...interface{}) ([]interface{}, error)

	Unsubscribe(string) error
	Unregister(string) error

	Join() error
	Leave() error
	Listen() error
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

func (d domain) Register(endpoint string, handler interface{}) error {
	c := core.NewID()
	if err := d.coreDomain.Register(endpoint, c, nil); err != nil {
		return err
	} else {
		d.mantleApp.registrations[c] = handler
		return nil
	}
}

func (d domain) Publish(endpoint string, args ...interface{}) error {
	return d.coreDomain.Publish(endpoint, args)
}

func (d domain) Call(endpoint string, args ...interface{}) ([]interface{}, error) {
	return d.coreDomain.Call(endpoint, args)
}

func (d domain) Unsubscribe(endpoint string) error {
	return d.coreDomain.Unsubscribe(endpoint)
}

func (d domain) Unregister(endpoint string) error {
	return d.coreDomain.Unregister(endpoint)
}

func (d domain) Leave() error {
	return d.coreDomain.Leave()
}

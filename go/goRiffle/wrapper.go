package goRiffle

import (
	"github.com/exis-io/coreRiffle"
)

type core struct {
	honcho coreRiffle.Honcho
}

type Domain interface {
	Subscribe(string, []interface{}) error
	Register(string, []interface{}) error

	Publish(string, ...interface{}) error
	Call(string, ...interface{}) ([]interface{}, error)

	Unsubscribe(string) error
	Unregister(string) error

	// Join(Connection) error
	Leave() error
}

type domain struct {
	core     *core
	mirror   coreRiffle.Domain
	handlers map[uint]interface{}
}

var wrapper *core

func NewDomain(name string) Domain {
	if wrapper == nil {
		h := coreRiffle.Initialize()

		wrapper = &core{
			honcho: h,
		}
	}

	d := domain{
		core:     wrapper,
		handlers: make(map[uint]interface{}),
	}

	d.mirror = wrapper.honcho.NewDomain(name, d)

	return d

	// d := &domain{
	// 	Delegate:      del,
	// 	honcho:        *c,
	// 	name:          name,
	// 	joined:        false,
	// 	subscriptions: make(map[uint]*boundEndpoint),
	// 	registrations: make(map[uint]*boundEndpoint),
	// }

	// c.domains = append(c.domains, d)
	// return d
}

func (d domain) Subscribe(endpoint string, handler []interface{}) error {
	if i, err := d.mirror.Subscribe(endpoint, []interface{}{}); err != nil {
		return err
	} else {
		d.handlers[i] = handler
		return nil
	}
}

func (d domain) Register(endpoint string, handler []interface{}) error {
	if i, err := d.mirror.Register(endpoint, []interface{}{}); err != nil {
		return err
	} else {
		d.handlers[i] = handler
		return nil
	}
}

func (d domain) Publish(endpoint string, args ...interface{}) error {
	err := d.mirror.Publish(endpoint, args)
	return err
}

func (d domain) Call(endpoint string, args ...interface{}) ([]interface{}, error) {
	args, err := d.mirror.Call(endpoint, args)
	return args, err
}

func (d domain) Unsubscribe(endpoint string) error {
	err := d.mirror.Unsubscribe(endpoint)
	return err
}

func (d domain) Unregister(endpoint string) error {
	err := d.mirror.Unregister(endpoint)
	return err
}

// func (d domain) Join(endpoint Connection) error {
// 	r := d.mirror.Join()
// 	return r
// }

func (d domain) Leave() error {
	err := d.mirror.Leave()
	return err
}

func (d domain) Invoke(endpoint string, id uint, args []interface{}) ([]interface{}, error) {
	return cumin(d.handlers[id], args)
}

func (d domain) OnJoin(string) {

}

func (d domain) OnLeave(string) {

}

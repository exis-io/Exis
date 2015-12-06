package goRiffle

import (
	"fmt"

	"github.com/exis-io/coreRiffle"
)

type Domain interface {
	Subscribe(string, []interface{}) error
	Register(string, []interface{}) error

	Publish(string, ...interface{}) error
	Call(string, ...interface{}) ([]interface{}, error)

	Unsubscribe(string) error
	Unregister(string) error

	Join() error
	Leave() error
}

type wrapper struct {
	honcho coreRiffle.Honcho
	conn   *websocketConnection
}

type domain struct {
	wrapper  *wrapper
	mirror   coreRiffle.Domain
	handlers map[uint]interface{}
}

var wrap *wrapper

func NewDomain(name string) Domain {
	if wrap == nil {
		h := coreRiffle.Initialize()

		wrap = &wrapper{
			honcho: h,
		}
	}

	d := domain{
		wrapper:  wrap,
		handlers: make(map[uint]interface{}),
	}

	d.mirror = wrap.honcho.NewDomain(name, d)
	return d
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

func (d domain) Join() error {
	// Open a new connection if we don't have one yet
	if d.wrapper.conn == nil {
		c, err := Open(coreRiffle.SandboxFabric)

		if err != nil {
			fmt.Println("Unable to open connection!")
			return err
		}

		d.wrapper.conn = c
		return d.mirror.Join()
	} else {
		// unimplemented
		return nil
	}
}

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

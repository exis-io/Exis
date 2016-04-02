package goRiffle

import "github.com/exis-io/core"

// A wrapper around the core domain. Re-exposes the methods from the core

type Domain interface {
	Subdomain(string) Domain

	Subscribe(string, interface{}, ...Options) error
	Register(string, interface{}, ...Options) error
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

// A handler (subscription or registration) with associated options
type boundHandler struct {
	handler interface{}
	options *Options
}

func NewDomain(name string) Domain {
	core.CuminLevel = core.CuminOff

	a := app{
		registrations: make(map[uint64]*boundHandler),
		subscriptions: make(map[uint64]*boundHandler),
		handlers:      make(map[uint64]*boundHandler),
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

func (d domain) Subscribe(endpoint string, handler interface{}, options ...Options) error {
	c := core.NewID()
	if err := d.coreDomain.Subscribe(endpoint, c, nil); err != nil {
		return err
	} else {
		d.mantleApp.subscriptions[c] = &boundHandler{handler: handler}
		return nil
	}
}

func (d domain) Register(endpoint string, handler interface{}, options ...Options) error {
	c := core.NewID()

	// TODO: panic on multiple options

	// These should not be two seperate calls, but will do for now
	if len(options) > 0 {
		if err := d.coreDomain.RegisterOptions(endpoint, c, nil, options[0].convertToJson()); err != nil {
			return err
		} else {
			d.mantleApp.registrations[c] = &boundHandler{handler: handler, options: &options[0]}
			return nil
		}
	} else {
		if err := d.coreDomain.Register(endpoint, c, nil); err != nil {
			return err
		} else {
			d.mantleApp.subscriptions[c] = &boundHandler{handler: handler}
			return nil
		}
	}
}

func (d domain) Publish(endpoint string, args ...interface{}) error {
	return d.coreDomain.Publish(endpoint, args)
}

func (d domain) Call(endpoint string, args ...interface{}) ([]interface{}, error) {

	// Check for options
	if len(args) > 0 {
		if opts, ok := args[len(args)-1].(Options); ok {
			Debug("Options detected")

			// done := make(chan interface{})

			// TODO: Place a special handler in the app that gets called over and over,
			// or spin off a func to handle results; bind on the done channel above
			if handler := opts.Progress; handler != nil {
				// d.mantleApp.handlers[]
				ret, id, err := d.coreDomain.CallOptions(endpoint, args[:1], opts.convertToJson())

				if err != nil {
					return nil, err
				}

				core.Cumin(handler, ret)

				Debug("Starting receive loop")

				for {
					ret, done := d.coreDomain.SuccessiveResult(endpoint, id)
					if done {
						return ret, nil
					} else {
						core.Cumin(handler, ret)
					}
				}
			} else {
				ret, _, err := d.coreDomain.CallOptions(endpoint, args[:1], opts.convertToJson())
				return ret, err
			}

		} else {
			// TODO: clean up redundant logic here
			return d.coreDomain.Call(endpoint, args)
		}
	} else {
		return d.coreDomain.Call(endpoint, args)
	}

}

func (d domain) Unsubscribe(endpoint string) error {
	// if err := d.coreDomain.Unsubscribe(endpoint); err != nil {
	//        delete(d.mantleApp.subscriptions
	//    }

	// TODO: track the endpoint along with the handler id, delete the handler using the code above
	return d.coreDomain.Unsubscribe(endpoint)
}

func (d domain) Unregister(endpoint string) error {
	return d.coreDomain.Unregister(endpoint)
}

func (d domain) Leave() error {
	return d.coreDomain.Leave()
}

/*
Notes on left side call and casting in general

- Optional casting might work well for call results using a switch statement
*/

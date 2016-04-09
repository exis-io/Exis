package riffle

import (
	"github.com/exis-io/core"
	"github.com/exis-io/core/shared"
)

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

	SetToken(string)
	GetToken() string
	LoadKey(string) error
}

type domain struct {
	coreDomain core.Domain
	mantleApp  *app
}

// A handler (subscription or registration) with associated options
type boundHandler struct {
	handler interface{}
	options *ProcessedOptions
}

// TEMPORARY TESTING
var appDomain core.Domain

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

	// TEMPORARY TESTING FOR MODELS
	appDomain = d.coreDomain

	return d

}

func (d domain) SetToken(tok string) {
	d.coreDomain.GetApp().SetToken(tok)
}

func (d domain) GetToken() string {
	return d.coreDomain.GetApp().GetToken()
}

func (d domain) LoadKey(p string) error {
	return d.coreDomain.GetApp().LoadKey(p)
}

func (d domain) Subdomain(name string) Domain {
	return domain{d.coreDomain.Subdomain(name), d.mantleApp}
}

func (d domain) Join() error {
	if c, err := shared.Open(core.Fabric); err != nil {
		return err
	} else if err := d.coreDomain.Join(c); err != nil {
		return err
	} else {
		// TEMPORARY TESTING
		//TestCoreModels(core.SetSession(appDomain))

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
	opts, jsonOpts := parseOptions(options)

	if opts != nil {

	}

	if err := d.coreDomain.Subscribe(endpoint, c, nil, jsonOpts); err != nil {
		return err
	} else {
		d.mantleApp.subscriptions[c] = &boundHandler{handler: handler}
		return nil
	}
}

func (d domain) Register(endpoint string, handler interface{}, options ...Options) error {
	c := core.NewID()
	opts, jsonOpts := parseOptions(options)

	if err := d.coreDomain.Register(endpoint, c, nil, jsonOpts); err != nil {
		return err
	} else {
		d.mantleApp.registrations[c] = &boundHandler{handler: handler, options: opts}
		return nil
	}
}

func (d domain) Publish(endpoint string, args ...interface{}) error {
	args, opts, jsonOpts := parseOptionsArgs(args)

	if opts != nil {

	}

	return d.coreDomain.Publish(endpoint, args, jsonOpts)
}

func (d domain) Call(endpoint string, args ...interface{}) ([]interface{}, error) {
	args, opts, jsonOpts := parseOptionsArgs(args)

	if opts != nil {
		if id, handler, ok := opts.progressive(); ok {
			d.mantleApp.handlers[id] = &boundHandler{handler: handler, options: opts}
			defer delete(d.mantleApp.handlers, id)
		}
	}

	return d.coreDomain.Call(endpoint, args, jsonOpts)
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

package core

// Helper methods for mantles. Operate functionally on Domains, triggering success or
// error callbacks based on the intended functionality

func MantleSubscribe(d Domain, endpoint string, cb uint, eb uint, handler uint, types []interface{}) {
	if err := d.Subscribe(endpoint, handler, types); err != nil {
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		d.GetApp().CallbackSend(cb)
	}
}

func MantleRegister(d Domain, endpoint string, cb uint, eb uint, handler uint, types []interface{}) {
	if err := d.Register(endpoint, handler, types); err != nil {
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		d.GetApp().CallbackSend(cb)
	}
}

func MantlePublish(d Domain, endpoint string, cb uint, eb uint, args []interface{}) {
	if err := d.Publish(endpoint, args); err != nil {
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		d.GetApp().CallbackSend(cb)
	}
}

func MantleCall(d Domain, endpoint string, cb uint, eb uint, args []interface{}, types []interface{}) {
	if results, err := d.Call(endpoint, args, types); err != nil {
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		d.GetApp().CallbackSend(cb, results)
	}
}

func MantleUnsubscribe(d Domain, endpoint string, cb uint, eb uint) {
	if err := d.Unsubscribe(endpoint); err != nil {
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		d.GetApp().CallbackSend(cb)
	}
}

func MantleUnregister(d Domain, endpoint string, cb uint, eb uint) {
	if err := d.Unregister(endpoint); err != nil {
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		d.GetApp().CallbackSend(cb)
	}
}

// Apply the arguments to the given function on this domain.
// If the function returns an error, callback with error, otherwise callback with success
// func (c domain) apply(fn func(*domain, string, uint, []interface{}) error, endpoint string, cb uint, eb uint, hn uint) {
//  // TODO: validate the endpoint, else errback
//  endpoint = makeEndpoint(c.name, endpoint)

//  // with function Subscribe:
//  if e := fn(&c, endpoint, cb); e != nil {
//      c.app.CallbackSend(eb, e.Error())
//  }

//  // Note that the above won't work for unsubscribe and unregister, since their success case returns nil
// }

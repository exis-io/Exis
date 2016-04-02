package core

// Helper methods for mantles. Operate functionally on Domains, triggering success or
// error callbacks based on the intended functionality. These functions are here to cut down
// on the redundancy of mantles

func MantleSubscribe(d Domain, endpoint string, cb uint64, eb uint64, handler uint64, types []interface{}) {
	if err := d.Subscribe(endpoint, handler, types, nil); err != nil {
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		d.GetApp().CallbackSend(cb)
	}
}

func MantleRegister(d Domain, endpoint string, cb uint64, eb uint64, handler uint64, types []interface{}) {
	if err := d.Register(endpoint, handler, types, nil); err != nil {
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		d.GetApp().CallbackSend(cb)
	}
}

func MantlePublish(d Domain, endpoint string, cb uint64, eb uint64, args []interface{}) {
	if err := d.Publish(endpoint, args, nil); err != nil {
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		d.GetApp().CallbackSend(cb)
	}
}

func MantleCall(d Domain, endpoint string, cb uint64, eb uint64, args []interface{}) {
	if results, err := d.Call(endpoint, args, nil); err != nil {
		d.RemoveCallExpect(cb)
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		if types, ok := d.GetCallExpect(cb); !ok && CuminLevel != CuminOff {
			// We were never asked for types. Don't do anything
			Info("Call for %v received, but no cumin enforcement present.", endpoint)
		} else {
			d.RemoveCallExpect(cb)
			if err := SoftCumin(types, results); err == nil {
				d.GetApp().CallbackSend(cb, results...)
			} else {
				d.GetApp().CallbackSend(eb, err.Error())
			}
		}
	}
}

func MantleUnsubscribe(d Domain, endpoint string, cb uint64, eb uint64) {
	if err := d.Unsubscribe(endpoint); err != nil {
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		d.GetApp().CallbackSend(cb)
	}
}

func MantleUnregister(d Domain, endpoint string, cb uint64, eb uint64) {
	if err := d.Unregister(endpoint); err != nil {
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		d.GetApp().CallbackSend(cb)
	}
}

// Apply the arguments to the given function on this domain.
// If the function returns an error, callback with error, otherwise callback with success
// func (c domain) apply(fn func(*domain, string, uint64, []interface{}) error, endpoint string, cb uint64, eb uint64, hn uint64) {
//  // TODO: validate the endpoint, else errback
//  endpoint = makeEndpoint(c.name, endpoint)

//  // with function Subscribe:
//  if e := fn(&c, endpoint, cb); e != nil {
//      c.app.CallbackSend(eb, e.Error())
//  }

//  // Note that the above won't work for unsubscribe and unregister, since their success case returns nil
// }

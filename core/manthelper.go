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

// Access the model object functions. Note these methods have identical interfaces
// to allow this one method to do all the heavy lifting
// TODO: implement cuminication of these results
func MantleModel(d Domain, target func(string, map[string]interface{}) ([]interface{}, error),
	collection string, query map[string]interface{}, cb uint64, eb uint64) {
	if r, err := target(collection, query); err != nil {
		d.GetApp().CallbackSend(eb, err.Error())
	} else {
		d.GetApp().CallbackSend(cb, r...)
	}
}

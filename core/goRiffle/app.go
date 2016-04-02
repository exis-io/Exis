package goRiffle

import "github.com/exis-io/core"

// Mantle only wrapper that holds onto handlers
// TODO: merge the handlers into one data structure, store reg/sub data in the boundHandler stuct
type app struct {
	registrations map[uint64]*boundHandler
	subscriptions map[uint64]*boundHandler
	handlers      map[uint64]*boundHandler // generalized handlers, used for progressive
	closing       chan bool                // set when the connection closes
	coreApp       core.App
}

// Main run loop. Start listening to the core and invoke handlers as appropriate
func (a *app) run() {
	for {
		cb := a.coreApp.CallbackListen()

		// TODO: paralleize handler invocation

		// 0 means close
		if cb.Id == 0 {
			Debug("Closing mantle receive loop")
			a.closing <- true
			break
		}

		if binding, ok := a.subscriptions[cb.Id]; ok {
			if _, err := core.Cumin(binding.handler, cb.Args); err != nil {
				Warn("%s", err.Error())
			}
		} else if binding, ok := a.registrations[cb.Id]; ok {
			// The first id for all calls is the yield id, or the id the result
			// of the call should go to
			yieldId := cb.Args[0].(uint64)
			args := cb.Args[1:]

			if binding.options == nil {
				if ret, err := core.Cumin(binding.handler, args); err != nil {
					Warn("%s", err.Error())
					a.coreApp.YieldError(yieldId, err.Error(), nil)
				} else {
					a.coreApp.Yield(yieldId, ret)
				}
			} else if _, _, ok := binding.options.progressive(); ok {

				// Can still apply cumin to the registered function, but the ret does not return immediately
				if ret, err := core.Cumin(binding.handler, args); err != nil {
					Warn("%s", err.Error())
					a.coreApp.YieldError(yieldId, err.Error(), nil)
				} else {
					progress := ret[0].(chan interface{})
					done := ret[1].(chan interface{})

					// Continue to handle progressive results
					// TODO: handle errors
					// TODO: detect channel closes
					go func() {
						for {
							select {
							case p := <-progress:
								a.coreApp.YieldOptions(yieldId, []interface{}{p}, map[string]interface{}{"progress": true})
							case d := <-done:
								a.coreApp.Yield(yieldId, []interface{}{d})
								break
							}
						}
					}()
				}
			}

		} else if binding, ok := a.handlers[cb.Id]; ok {
			if _, err := core.Cumin(binding.handler, cb.Args); err != nil {
				Warn("%s", err.Error())
			}
		} else {
			Warn("No handler for id: %d", cb.Id)
		}
	}
}

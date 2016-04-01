package goRiffle

import "github.com/exis-io/core"

// Mantle only wrapper that holds onto handlers
type app struct {
	registrations map[uint64]interface{}
	subscriptions map[uint64]interface{}
	closing       chan bool // set when the connection closes
	coreApp       core.App
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

		Debug("Received callback %d", cb.Id)
		Debug("Current subscriptions: %v")

		if handler, ok := a.subscriptions[cb.Id]; ok {
			if _, err := core.Cumin(handler, cb.Args); err != nil {
				Warn("%s", err.Error())
			}
		} else if handler, ok := a.registrations[cb.Id]; ok {
			core.Cumin(handler, cb.Args)
		} else {
			Warn("No handler for id: %d", cb.Id)
		}
	}
}

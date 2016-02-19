package core

import (
	"github.com/gopherjs/gopherjs/js"
)

type Deferred interface {
	Resolve(...interface{})
	Reject(...interface{})
	Notify(...interface{})
	Promise() *js.Object
}

type deferred struct {
	this    *js.Object
	promise *js.Object
}

func Defer() Deferred {
	q := js.Global.Get("Q").Get("defer").Invoke()
	d := &deferred{
		this:    q,
		promise: q.Get("promise"),
	}

	return d
}

func (d *deferred) Resolve(args ...interface{}) {
	d.this.Get("resolve").Invoke(args...)
}

func (d *deferred) Reject(args ...interface{}) {
	d.this.Get("reject").Invoke(args...)
}

func (d *deferred) Notify(args ...interface{}) {
	d.this.Get("notify").Invoke(args...)
}

func (d *deferred) Promise() *js.Object {
	return d.promise
}

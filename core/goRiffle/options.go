package goRiffle

// Possible options for all the kinds of operation. Preliminary, please review and revise
// Any of the four major operations can accept options objects, every kind of option
// does not apply to every kind of call

type Options struct {
	// Accepts a fuction
	// Usable by: Register, Call
	// If Registering, the function should return two channels immediately. Push on the
	// first channel for progress and the second channel for completion. Cumin is applied
	Progress interface{}
}

// Transforms the options object to a json for consumption by the core
func (o Options) convertToJson() map[string]interface{} {
	r := make(map[string]interface{})

	if o.Progress != nil {
		r["progress"] = true
	}

	return r
}

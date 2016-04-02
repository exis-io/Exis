package goRiffle

import "github.com/exis-io/core"

// Possible options for all the kinds of operation.
// Any of the four major operations can accept options objects, every kind of option
// does not apply to every kind of call

type Options struct {
	// Accepts a fuction
	// Usable by: Register, Call
	// If Registering, the function should return two channels immediately. Push on the
	// first channel for progress and the second channel for completion. Cumin is applied
	Progress interface{}
}

// Holds a processed set of options and the core-ready form of those options
type ProcessedOptions struct {
	Options
	Json map[string]interface{}
}

// Screens a list of arguments for passed options, expects it as the last argument
// If found, returns the agtument list without the options object, the processed options, and json ready for the core
// Else returns the original arguments
func parseOptionsArgs(args []interface{}) ([]interface{}, *ProcessedOptions, map[string]interface{}) {
	if len(args) == 0 {
		return args, nil, nil
	}

	if opts, ok := args[len(args)-1].(Options); !ok {
		return args, nil, nil
	} else {
		o, j := parseOptions([]Options{opts})
		return args[:len(args)-1], o, j
	}
}

// Take a list of options and parse them. Return the processed options and the json if well formed
func parseOptions(options []Options) (*ProcessedOptions, map[string]interface{}) {
	// TODO: err on more than one options object
	if len(options) == 0 {
		return nil, nil
	}

	opts := options[0]
	p := &ProcessedOptions{Options: opts, Json: make(map[string]interface{})}

	if opts.Progress != nil {
		p.Json["progress"] = core.NewID()
	}

	return p, p.Json
}

// If the progressive option is found, return the callback id to be used for the progress handler
// and the progress handler itself
func (p *ProcessedOptions) progressive() (uint64, interface{}, bool) {
	if p.Options.Progress != nil {
		return p.Json["progress"].(uint64), p.Options.Progress, true
	} else {
		return 0, nil, false
	}
}

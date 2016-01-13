// Example Want Definitions Recv - defines how to use want for receiving actions
// ARBITER set action defs

// In NodeJS you must import jsriffle:
var riffle = require('jsriffle');

// After importing riffle, simply add types to
// function declarations wrapped with riffle.want
this.Register("endpoint", riffle.want(function(s) {
    console.log(s);
}, String));
// the registered endpoint will only execute
// if it is provided a String

// Nothing is returned
riffle.want(function () { ... })

// The primitives
riffle.want(function (s) { ... }, String)
riffle.want(function (i) { ... }, Number)
riffle.want(function (f) { ... }, Number)
riffle.want(function (b) { ... }, Boolean)

// Collections
// A list of anything
riffle.want(function (l) { ... }, [])
// A dict of anything
riffle.want(function (d) { ... }, {})

// Many arguments
// This function requires a string and 2 numbers
riffle.want(function (s, i, f) { ... }, String, Number, Number)
// This function requires a string and a list of numbers
riffle.want(function (s, l) { ... }, String, [Number])

// End Example Want Definitions Recv

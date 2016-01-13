// Example Want Definitions Send - defines how to use want for sending actions
// ARBITER set action defs

// In NodeJS you must import jsriffle:
var riffle = require('jsriffle');

// First setup your domain
var app = riffle.Domain("xs.demo.test");
// Now setup who you want to communicate with
var backend = app.Subdomain("backend");

// Calls are asynchronous code, so they use
// promises, like so:
backend.Call("endpoint", "arg1").then(
    riffle.wait(function (s) {
        console.log("I got a string: " + s);
    }, String), function (err) {
        console.log("ERROR: " + err);
    });
// The call above sends a string, and waits for
// a string, if the backend doesn't return a string
// then the error function will be called instead.

// You can call without requiring anything in return
backend.Call("hello", "hi");

// Waiting for primitives
backend.Call("hello").then(
    riffle.wait(function (s) {...}, String)
);
backend.Call("hello").then(
    riffle.wait(function (n) {...}, Number)
);
backend.Call("hello").then(
    riffle.wait(function (b) {...}, Boolean)
);

// Collections
backend.Call("hello").then(
    riffle.wait(function (stringList) {...}, [String])
);
backend.Call("hello").then(
    riffle.wait(function (myDict) {...}, {name: String})
);
// The argument myDict above will require a dict with the key name
// which is a String.

// Many arguments
// s is str, i is int, b is boolean
backend.Call("hello").then(
    riffle.wait(function (s, i, b) {...}, String, Number, Boolean)
);
// d is str, e is a list of int's
backend.Call("hello").then(
    riffle.wait(function (d, e) {...}, String, [Number])
);

// End Example Want Definitions Send

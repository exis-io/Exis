var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.Subdomain("backend");
var client = app.Subdomain("client");

client.onJoin = function() {
    // Example Tour Reg/Call Lesson 1 - our first basic example
    backend.Call("myFirstCall", "Hello").then(riffle.wait(function (s) {
        console.log(s); // Expects a String, like "Hello World"
    }, String),
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Tour Reg/Call Lesson 1
        
    // Example Tour Reg/Call Lesson 2 Works - type enforcement good
    backend.Call("iWantStrings", "Hi").then(riffle.wait(function (s) {
        console.log(s); // Expects a String, like "Thanks for saying Hi"
    }, String),
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Tour Reg/Call Lesson 2 Works
        
    // Example Tour Reg/Call Lesson 2 Fails - type enforcement bad
    backend.Call("iWantInts", "Hi").then(riffle.wait(function (s) {
        console.log(s); // Expects a String, like "Thanks for saying Hi"
    }, String),
    function (err) {
        console.log("ERROR: ", err); // Errors with "Cumin: expecting primitive float, got string"
    });
    // End Example Tour Reg/Call Lesson 2 Fails
    
    // Example Tour Reg/Call Lesson 2 Wait Check - type enforcement on wait
    backend.Call("iGiveInts", "Hi").then(riffle.wait(function (s) {
        console.log(s); // Expects a String, like "Hello"
    }, String),
    function (err) {
        console.log("ERROR: ", err); // Errors with "Cumin: expecting primitive float, got string"
    });
    // End Example Tour Reg/Call Lesson 2 Wait Check
    
    // Example Tour Reg/Call Lesson 3 Works - collections of types
    backend.Call("iWantManyStrings", ["This", "is", "cool"]).then(riffle.wait(function (s) {
        console.log(s); // Expects a String, like "Thanks for 3 strings!"
    }, String),
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Tour Reg/Call Lesson 3 Works
    
    // Example Tour Reg/Call Lesson 3 Fails - collections of types
    backend.Call("iWantManyInts", [0, 1, "two"]).then(riffle.wait(function (s) {
        console.log(s); // Expects a String, like "Thanks for 3 ints!"
    }, String),
    function (err) {
        console.log("ERROR: ", err); // Errors with "Cumin: expecting primitive float, got string"
    });
    // End Example Tour Reg/Call Lesson 3 Fails
    
    console.log("___SETUPCOMPLETE___");

};

client.Join()

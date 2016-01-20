var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.Subdomain("backend");
var client = app.Subdomain("client");

client.onJoin = function() {

    // Example Reg/Call str str - Basic reg expects string, returns string
    backend.Call("regStrStr", "Hello").then(riffle.wait(function (s) {
        console.log(s); // Expects a String, like "Hello World"
    }, String),
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Reg/Call str str
    
    // Example Reg/Call str int - Basic reg expects string, returns int
    backend.Call("regStrInt", "Hello").then(riffle.wait(function (i) {
        console.log(i); // Expects an int, like 42
    }, String),
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Reg/Call str int
    
    // Example Reg/Call int str - Basic reg expects int, returns str
    backend.Call("regIntStr", 42).then(riffle.wait(function (s) {
        console.log(s); // Expects a String, like "Hello World"
    }, String),
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Reg/Call int str
};

client.Join()

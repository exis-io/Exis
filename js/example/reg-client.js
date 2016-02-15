var riffle = require('jsriffle');

riffle.setFabricLocal();
riffle.setLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.subdomain("backend");
var client = app.subdomain("client");

client.onJoin = function() {

    // Example Reg/Call str str - Basic reg expects string, returns string
    backend.call("regStrStr", "Hello").want(String).then(function (s) {
        console.log(s); // Expects a String, like "Hello World"
    },
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Reg/Call str str
    
    // Example Reg/Call str int - Basic reg expects string, returns int
    backend.call("regStrInt", "Hello").want(Number).then(function (i) {
        console.log(i); // Expects an int, like 42
    },
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Reg/Call str int
    
    // Example Reg/Call int str - Basic reg expects int, returns str
    backend.call("regIntStr", 42).want(String).then(function (s) {
        console.log(s); // Expects a String, like "Hello World"
    },
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Reg/Call int str
};

client.join()

var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.Subdomain("backend");
var client = app.Subdomain("client");

client.onJoin = function() {

    backend.Call("basicReg", "Hello").then(riffle.wait(function (s) {
        console.log(s);
    }, String),
    function (err) {
        console.log("ERROR: ", err);
    });

    backend.Call("basicReg1", "Hello").then(riffle.wait(function (s, n) {
        console.log(s, n);
    }, String, Number),
    function (err) {
        console.log("ERROR: ", err);
    });
};

client.Join()

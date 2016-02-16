var riffle = require('jsriffle');

riffle.setFabricLocal();
riffle.setLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.subdomain("backend");
var client = app.subdomain("client");

client.onJoin = function() {
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Test Restart before call - Does restarting before a call work?
    // Trying to restart the node before the call happens, but need to insert
    // artificial delay to make this happen!
    console.log("___NODERESTART___");
    setTimeout(function (){
        backend.call("restartBeforeC", "Restart before call").want(String).then(function(s) {
            console.log(s); // Expects a String, like "Restart before call works"
        });
    }, 6000);
    // End Example Test Restart before call

    /////////////////////////////////////////////////////////////////////////////////////
    // Example Test Restart after reg - Does restarting after a register work
    setTimeout(function (){
        backend.call("restartAfterR", "Restart after reg").want(String).then(function(s) {
            console.log(s); // Expects a String, like "Restart after reg works"
        });
    }, 4000);
    // End Example Test Restart after reg

    console.log("___SETUPCOMPLETE___");
};

client.join()

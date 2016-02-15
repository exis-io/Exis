var riffle = require('jsriffle');

riffle.setFabricLocal();
riffle.setLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.subdomain("backend");
var client = app.subdomain("client");

backend.onJoin = function() {
    // Example Test Restart before call - Does restarting before a call work?
    // ARBITER skip test
    this.register("restartBeforeC", riffle.want(String), function(s) {
        console.log(s) // Expects a str, like "Restart before call"
        return s + " works";
    });
    // End Example Test Restart before call
    
    // Example Test Restart after reg - Does restarting after a register work
    // ARBITER skip test
    this.register("restartAfterR", riffle.want(String), function(s) {
        console.log(s) // Expects a str, like "Restart after reg"
        return s + " works"
    });
    setTimeout(function (){
        console.log("___NODERESTART___");
    }, 500);
    // End Example Test Restart after reg



};

backend.join()


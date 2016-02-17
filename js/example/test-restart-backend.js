var riffle = require('jsriffle');

riffle.setFabricLocal();
riffle.setLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.subdomain("backend");
var client = app.subdomain("client");

backend.onJoin = function() {
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Test Restart before call - Does restarting before a call work?
    this.register("restartBeforeC", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Restart before call"
        return s + " works";
    }, String));
    // End Example Test Restart before call

    /////////////////////////////////////////////////////////////////////////////////////
    // Example Test Restart after reg - Does restarting after a register work
    this.register("restartAfterR", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Restart after reg"
        return s + " works";
    }, String));
    setTimeout(function (){
        console.log("___NODERESTART___");
    }, 1000);
    // End Example Test Restart after reg

    console.log("___SETUPCOMPLETE___");
};

backend.join()


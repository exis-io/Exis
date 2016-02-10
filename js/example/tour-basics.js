var riffle = require('jsriffle');

riffle.setFabricLocal();
riffle.setLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.subdomain("backend");
var client = app.subdomain("client");

backend.onJoin = function() {
    // Example Tour Basics 1 - simple print
    // ARBITER set action simple
    console.log("Hello World");
    // End Example Tour Basics 1
        
    // Example Tour Basics 2 - async NOTE this code won't run since pub/sub is in line
    this.subscribe("async", riffle.want(function(i) {
        console.log(i);
    }, Number));
    // End Example Tour Basics 2
    
    // Example Tour Basics 2 - async NOTE this code won't run since pub/sub is in line
    for(var i = 0; i < 10; i++) {
        backend.publish("async", i);
    }
    // End Example Tour Basics 2
        
    console.log("___SETUPCOMPLETE___");

};

backend.join()

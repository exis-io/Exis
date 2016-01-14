var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.Subdomain("backend");
var client = app.Subdomain("client");

backend.onJoin = function() {
    // Example Tour Basics 1 - simple print
    // ARBITER set action simple
    console.log("Hello World");
    // End Example Tour Basics 1
        
    // Example Tour Basics 2 - async NOTE this code won't run since pub/sub is in line
    this.Subscribe("async", riffle.want(function(i) {
        console.log(i);
    }, Number));
    // End Example Tour Basics 2
    
    // Example Tour Basics 2 - async NOTE this code won't run since pub/sub is in line
    for(var i = 0; i < 10; i++) {
        backend.Publish("async", i);
    }
    // End Example Tour Basics 2
        
    console.log("___SETUPCOMPLETE___");

};

backend.Join()

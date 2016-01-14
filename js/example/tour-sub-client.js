var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.Subdomain("backend");
var client = app.Subdomain("client");

client.onJoin = function() {
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Pub/Sub Lesson 1 - our first basic example
    backend.Publish("myFirstSub", "Hello");
    // End Example Tour Pub/Sub Lesson 1
        
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Pub/Sub Lesson 2 Works - type enforcement good
    backend.Publish("iWantStrings", "Hi").then(function() {
        console.log("Publish to iWantStrings complete");
    },
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Tour Pub/Sub Lesson 2 Works
        
    // Example Tour Pub/Sub Lesson 2 Fails - type enforcement bad
    backend.Publish("iWantInts", "Hi").then(function () {
        console.log("Publish to iWantInts complete");
    },
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Tour Pub/Sub Lesson 2 Fails
    
    
    console.log("___SETUPCOMPLETE___");

};

client.Join()

var riffle = require('jsriffle');

riffle.setFabricLocal();
riffle.setLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.subdomain("backend");
var client = app.subdomain("client");

client.onJoin = function() {
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Pub/Sub Lesson 1 - our first basic example
    backend.publish("myFirstSub", "Hello");
    // End Example Tour Pub/Sub Lesson 1
        
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Pub/Sub Lesson 2 Works - type enforcement good
    backend.publish("iWantStrings", "Hi").then(function() {
        console.log("Publish to iWantStrings complete");
    },
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Tour Pub/Sub Lesson 2 Works
        
    // Example Tour Pub/Sub Lesson 2 Fails - type enforcement bad
    backend.publish("iWantInts", "Hi").then(function () {
        console.log("Publish to iWantInts complete");
    },
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Tour Pub/Sub Lesson 2 Fails
    
    
    console.log("___SETUPCOMPLETE___");

};

client.join()

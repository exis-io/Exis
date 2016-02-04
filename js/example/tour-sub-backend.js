var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.subdomain("backend");
var client = app.subdomain("client");

backend.onJoin = function() {
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Pub/Sub Lesson 1 - our first basic example
    this.subscribe("myFirstSub", riffle.want(function(s) {
        console.log("I got " + s); // Expects a String, like "I got Hello"
    }, String));
    // Somewhere in another file or program...
    this.subscribe("myFirstSub", riffle.want(function(s) {
        console.log("I got " + s + ", too!"); // Expects a String, like "I got Hello, too!"
    }, String));
    // End Example Tour Pub/Sub Lesson 1
        
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Pub/Sub Lesson 2 Works - type enforcement good
    this.subscribe("iWantStrings", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Hi"
    }, String));
    // End Example Tour Pub/Sub Lesson 2 Works
        
    // Example Tour Pub/Sub Lesson 2 Fails - type enforcement bad
    this.subscribe("iWantInts", riffle.want(function(i) {
        // This function won't execute
        console.log("You won't see me :)");
    }, Number));
    // End Example Tour Pub/Sub Lesson 2 Fails
    
    
    console.log("___SETUPCOMPLETE___");

};

backend.join()

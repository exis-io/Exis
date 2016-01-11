var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.Subdomain("backend");
var client = app.Subdomain("client");

backend.onJoin = function() {
    // Example Tour Reg/Call Lesson 1 - our first basic example
    this.Register("myFirstCall", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Hello"
        return s + " World";
    }, String));
    // End Example Tour Reg/Call Lesson 1
        
    // Example Tour Reg/Call Lesson 2 Works - type enforcement good
    this.Register("iWantStrings", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Hi"
        return "Thanks for saying " + s;
    }, String));
    // End Example Tour Reg/Call Lesson 2 Works
        
    // Example Tour Reg/Call Lesson 2 Fails - type enforcement bad
    this.Register("iWantInts", riffle.want(function(i) {
        console.log(i); // Expects a Number, like 42
        return "Thanks for sending int " + i;
    }, Number));
    // End Example Tour Reg/Call Lesson 2 Fails
        
    console.log("___SETUPCOMPLETE___");

};

backend.Join()

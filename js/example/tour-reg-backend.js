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
    
    // Example Tour Reg/Call Lesson 2 Wait Check - type enforcement on wait
    this.Register("iGiveInts", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Hi"
        return 42;
    }, String));
    // End Example Tour Reg/Call Lesson 2 Wait Check
    
    // Example Tour Reg/Call Lesson 3 Works - collections of types
    this.Register("iWantManyStrings", riffle.want(function(s) {
        console.log(s); // Expects a new riffle.ArrayWithType(String), like ["This", "is", "cool"]
        return "Thanks for " + s.length + " strings!"
    }, new riffle.ArrayWithType(String)));
    // End Example Tour Reg/Call Lesson 3 Works
    
    // Example Tour Reg/Call Lesson 3 Fails - collections of types
    this.Register("iWantManyInts", riffle.want(function(s) {
        console.log(s); // Expects a new riffle.ArrayWithType(Number), like [0, 1, 2]
        return "Thanks for " + s.length + " ints!"
    }, new riffle.ArrayWithType(Number)));
    // End Example Tour Reg/Call Lesson 3 Fails
        
    console.log("___SETUPCOMPLETE___");

};

backend.Join()

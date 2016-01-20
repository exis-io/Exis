var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.Subdomain("backend");
var client = app.Subdomain("client");

backend.onJoin = function() {
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Reg/Call Lesson 1 - our first basic example
    this.Register("myFirstFunc", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Hello"
        return s + " World";
    }, String));
    // End Example Tour Reg/Call Lesson 1
        
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Reg/Call Lesson 2 Works - type enforcement good
    this.Register("iWantStrings", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Hi"
        return "Thanks for saying " + s;
    }, String));
    // End Example Tour Reg/Call Lesson 2 Works
        
    // Example Tour Reg/Call Lesson 2 Fails - type enforcement bad
    this.Register("iWantInts", riffle.want(function(i) {
        console.log(i);
        return "Thanks for sending int " + i;
    }, Number));
    // End Example Tour Reg/Call Lesson 2 Fails
    
    // Example Tour Reg/Call Lesson 2 Wait Check - type enforcement on wait
    this.Register("iGiveInts", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Hi"
        return 42;
    }, String));
    // End Example Tour Reg/Call Lesson 2 Wait Check
    
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Reg/Call Lesson 3 Works - collections of types
    this.Register("iWantManyStrings", riffle.want(function(s) {
        console.log(s.join(" ")); // Expects a String, like "This is cool"
        return "Thanks for " + s.length + " strings!"
    }, [String]));
    // End Example Tour Reg/Call Lesson 3 Works
    
    // Example Tour Reg/Call Lesson 3 Fails - collections of types
    this.Register("iWantManyInts", riffle.want(function(s) {
        console.log(s);
        return "Thanks for " + s.length + " ints!"
    }, [Number]));
    // End Example Tour Reg/Call Lesson 3 Fails
        
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Reg/Call Lesson 4 Basic Student - intro to classes
    function Student() {
        this.name = String;
        this.age = Number;
        this.studentID = Number;
    }
    Student.prototype.toString = function() {
        return this.name + ", Age: " + this.age + ", ID: " + this.studentID;
    }
    this.Register("sendStudent", riffle.want(function(s) {
        console.log(s.toString()); // Expects a String, like "John Smith, Age: 18, ID: 1234"
    }, riffle.ModelObject(Student)));
    // End Example Tour Reg/Call Lesson 4 Basic Student
    console.log("___SETUPCOMPLETE___");
    
};

backend.Join()

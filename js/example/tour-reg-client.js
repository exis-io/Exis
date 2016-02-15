var riffle = require('jsriffle');

riffle.setFabricLocal();
riffle.setLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.subdomain("backend");
var client = app.subdomain("client");

client.onJoin = function() {
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Reg/Call Lesson 1 - our first basic example
    backend.call("myFirstFunc", "Hello").want(String).then(function (s) {
        console.log(s); // Expects a String, like "Hello World"
    },
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Tour Reg/Call Lesson 1
        
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Reg/Call Lesson 2 Works - type enforcement good
    backend.call("iWantStrings", "Hi").want(String).then(function (s) {
        console.log(s); // Expects a String, like "Thanks for saying Hi"
    },
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Tour Reg/Call Lesson 2 Works
        
    // Example Tour Reg/Call Lesson 2 Fails - type enforcement bad
    backend.call("iWantInts", "Hi").want(String).then(function (s) {
        console.log(s);
    },
    function (err) {
        console.log(err) // Expects a String, like "wamp.error.invalid_argument: Cumin: expecting primitive float, got string"
    });
    // End Example Tour Reg/Call Lesson 2 Fails
    
    // Example Tour Reg/Call Lesson 2 Want Check - type enforcement on want
    backend.call("iGiveInts", "Hi").want(String).then(function (s) {
        console.log(s);
    },
    function (err) {
        console.log(err); // Expects a String, like "Cumin: expecting primitive str, got int"
    });
    // End Example Tour Reg/Call Lesson 2 want Check
    
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Reg/Call Lesson 3 Works - collections of types
    backend.call("iWantManyStrings", ["This", "is", "cool"]).want(String).then(function (s) {
        console.log(s); // Expects a String, like "Thanks for 3 strings!"
    },
    function (err) {
        console.log("ERROR: ", err);
    });
    // End Example Tour Reg/Call Lesson 3 Works
    
    // Example Tour Reg/Call Lesson 3 Fails - collections of types
    backend.call("iWantManyInts", [0, 1, "two"]).want(String).then(function (s) {
        console.log(s);
    },
    function (err) {
        console.log("ERROR: ", err); // Expects a String, like "Cumin: expecting primitive float, got string"
    });
    // End Example Tour Reg/Call Lesson 3 Fails
    
    /////////////////////////////////////////////////////////////////////////////////////
    // Example Tour Reg/Call Lesson 4 Basic Student - intro to classes
    function Student() {
        this.name = "Student Name";
        this.age = 20;
        this.studentID = 0;
    }
    var s = new Student();
    s.name = "John Smith";
    s.age = 18;
    s.studentID = 1234;
    backend.call("sendStudent", s);
    // End Example Tour Reg/Call Lesson 4 Basic Student
    
    
    //var student = new riffle.ObjectModel(Student);
    
    console.log("___SETUPCOMPLETE___");

};

client.join()

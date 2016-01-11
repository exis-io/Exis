var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.Subdomain("backend");
var client = app.Subdomain("client");

backend.onJoin = function() {
    // Example Reg/Call str str - Basic reg expects string, returns string
    this.Register("regStrStr", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Hello"
        return "Hello World";
    }, String));
    // End Example Reg/Call str str
        
    // Example Reg/Call str int - Basic reg expects string, returns int
    this.Register("regStrInt", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Hello"
        return 42;
    }, String));
    // End Example Reg/Call str int
        
    // Example Reg/Call int str - Basic reg expects int, returns str
    this.Register("regIntStr", riffle.want(function(i) {
        console.log(i); // Expects a Number, like 42
        return "Hello World";
    }, Number));
    // End Example Reg/Call int str

};

backend.Join()

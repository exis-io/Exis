var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.Subdomain("backend");
var client = app.Subdomain("client");

backend.onJoin = function() {

    this.Register("basicReg", riffle.want(function(s) {
        console.log(s);
        return "Hello World";
    }, String));
};

backend.Join()

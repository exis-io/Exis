var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.Subdomain("backend");
var client = app.Subdomain("client");

client.onJoin = function() {

    // Example Pub/Sub Basic - a very basic pub/sub example
    backend.Publish("basicSub", "Hello");
    // End Example Pub/Sub Basic
    
    // Example Pub/Sub Basic Two - a basic pub/sub example
    backend.Publish("basicSubTwo", "Hello", 3);
    // End Example Pub/Sub Basic Two

};

client.Join()

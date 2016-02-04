var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.subdomain("backend");
var client = app.subdomain("client");

client.onJoin = function() {

    // Example Pub/Sub Basic - a very basic pub/sub example
    backend.publish("basicSub", "Hello");
    // End Example Pub/Sub Basic
    
    // Example Pub/Sub Basic Two - a basic pub/sub example
    backend.publish("basicSubTwo", "Hello", 3);
    // End Example Pub/Sub Basic Two

};

client.join()

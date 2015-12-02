var riffle = require('jsriffle');
riffle.setDevFabric();

var app = new riffle.Domain("xs.demo");
var me = app.subdomain("server");


me.onJoin = function() {
    console.log("Domain " + this.domain + " joined");

    this.subscribe('sub', function (args) {
        console.log("Publish received:", args[0], args[1]);
    });

    this.register('register', function(args) {
        console.log("Call received: ",  args[0], args[1]);
        return "Pong"
    });
};

me.join();

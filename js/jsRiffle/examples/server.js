var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.damouse");
var me = app.Subdomain("alpha");

me.onJoin = function() {
    console.log("Receiever Joined");

    this.Subscribe("sub", function() {
        console.log("Received a publish!")
    })

    this.Register("reg", function() {
        console.log("Received a publish!")
    })
};

me.Join()

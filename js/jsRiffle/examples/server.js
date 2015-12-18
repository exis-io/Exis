var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.damouse");
var me = app.Subdomain("alpha");

me.onJoin = function() {
    console.log("Receiever Joined");

    this.Subscribe("sub", function() {
        console.log("Received a publish!");
    }).then( function(args){ 
        console.log("Success with args:", args) 
    }, function(args){ 
         console.log("Error with args: ", args) 
    });

    this.Register("reg", function(args) {
        console.log("Received a Call: ", args)
        return true;
    });
};

me.Join()



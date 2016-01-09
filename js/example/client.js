var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.damouse");
var receiver = app.Subdomain("alpha");
var me = app.Subdomain("beta");

var nick = {first: "Nick", last: "Hyatt"};

me.onJoin = function() {
    console.log("Sender Joined");

    //receiver.Publish("sub", nick);

    receiver.Call("reg", nick).then(function(results){
        console.log("Results: ", results);
    }, function(error) {
        console.log("Call failed with error: ", error);
    });
};

me.Join()

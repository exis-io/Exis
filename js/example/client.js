
// "Real" client.js testing code
var riffle = require('jsriffle');

riffle.setFabricLocal();
riffle.setLogLevelDebug();

var app = riffle.Domain("xs.damouse");
var receiver = app.subdomain("alpha");
var me = app.subdomain("beta");

me.onJoin = function() {
    console.log("Sender Joined");

    receiver.call("iGiveInts", "Hi").wait([Number]).then(function(a) {
        console.log("Result: ", a);
    },
    function (err) {
        console.log("ERROR: ", err); 
    });

    // receiver.call("iGiveInts", "Hi").then(function(a) {
    //     console.log("Result: ", a);
    // },
    // function (err) {
    //     console.log("ERROR: ", err); 
    // });

};

me.join()

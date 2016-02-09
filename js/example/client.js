
// "Real" client.js testing code
var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.damouse");
var receiver = app.subdomain("alpha");
var me = app.subdomain("beta");


me.onJoin = function() {
    console.log("Sender Joined");

    receiver.call("iGiveInts", "Hi").then(riffle.wait(function(a) {
        console.log("Result: ", a);
    }, Number),
    function (err) {
        console.log("ERROR: ", err); // Expects a String, like "Cumin: expecting primitive float, got string"
    });

};

me.join()

// Testing auth methods 
// var riffle = require('jsriffle');
// riffle.SetLogLevelDebug();

// var app = riffle.Domain("xs.demo.deemouse.jstest");
// var me = app.subdomain("alpha");

// me.onJoin = function() {
//     console.log("Client Joined");
// };

// me.SetToken("zdyiG7Gl9ur0rJV7GtwHMHFaEMvDaqnyjbg0K65aCwuuISLBJg3FGCtMc30WOwacH8MbGH.WRZsjJVNh4n9DXh8RZbRwoy2VuigTblczPK0jejtP6uuTCXuj2yYjGiXThhjfYiJnRCALsu79AHO7dtjOfgyzJ8hGccKtpbYNH5o_")
// me.join()

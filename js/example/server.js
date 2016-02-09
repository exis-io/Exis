
var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.damouse");
var me = app.subdomain("alpha");


me.onJoin = function() {
    console.log("Receiever Joined");

    // Example Tour Reg/Call Lesson 2 Wait Check - type enforcement on wait
    this.register("iGiveInts", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Hi"
        return 1;
    }, String));
    // End Example Tour Reg/Call Lesson 2 Wait Check

};

me.join()

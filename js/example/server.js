
var riffle = require('jsriffle');

riffle.setFabricLocal();
riffle.setLogLevelDebug();

var app = riffle.Domain("xs.damouse");
var me = app.subdomain("alpha");


me.onJoin = function() {
    console.log("Receiever Joined");

    var self = this;

    this.register("iGiveInts", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Hi"

        console.log("LEAVEING")
        self.leave();
        return [1, 2];
    }, String));

};

me.join()

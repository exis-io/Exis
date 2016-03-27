// "Real" client.js testing code
var riffle = require('jsriffle');

riffle.setFabricLocal();
riffle.setLogLevelDebug();

var app = riffle.Domain("xs.damouse");
var receiver = app.subdomain("alpha");
var me = app.subdomain("beta");

me.onJoin = function() {
  console.log("Sender Joined");

  // called second
  this.register("steptwo", riffle.want(function(s) {
    console.log("Returning from steptwo");
    return "Sender.stepTwo"
  }, String));

  receiver.call("stepone", "Sender.stepZero").then(function(a) {
      console.log("Result: ", a);
    },
    function(err) {
      console.log("ERROR: ", err);
    });

};

me.join()

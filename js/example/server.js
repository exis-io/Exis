var riffle = require('jsriffle');

riffle.setFabricLocal();
riffle.setLogLevelDebug();

var app = riffle.Domain("xs.damouse");
var sender = app.subdomain("beta");
var me = app.subdomain("alpha");


me.onJoin = function() {
  console.log("Receiever Joined");

  var self = this;

  // Called first
  this.register("stepone", riffle.want(function(s) {
    console.log("Returning from stepone");

    return sender.call("steptwo", "Receiever.stepOne").then(function(a) {
      console.log("Receiver.Result: ", a);
      return "Receiver.Result: " + a
    });

    return "Receiever.stepOne"

  }, String));

};

me.join()

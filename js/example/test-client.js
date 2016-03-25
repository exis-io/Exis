var riffle = require('jsriffle');

riffle.setFabricLocal();
riffle.setLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.subdomain("backend");
var client = app.subdomain("client");

client.onJoin = function() {
  /////////////////////////////////////////////////////////////////////////////////////
  // Example Test Client leave - does the client side leave properly
  var self = this;
  this.onLeave = function() {
    console.log("On Leave Triggered"); // Expects a String, like "On Leave Triggered"
  };
  backend.call("testClientLeave", "Leave").want(String).then(function(s) {
      self.leave();
    },
    function(err) {
      console.log("ERROR: ", err);
    });
  // End Example Test Client leave

  // Example Test Backend leave - does the client side leave properly
  backend.call("testBackendLeave", "Leave").want(String).then(function(s) {
      console.log("GOT: ", s);
    },
    function(err) {
      console.log("ERROR: ", err);
    });
  // End Example Test Backend leave

  // Example Test Returning Nested Deferred - demonstrates returning nested deferreds
  this.register("testClientNested", riffle.want(function(s) {
    return s + ", third"
  }, String));

  receiver.call("testBackendNested", "first").then(function(a) {
      console.log(a); // Expects a String, like "first, second, third, fourth"
    },
    function(err) {
      console.log("ERROR: ", err);
    });

  // End Example Test Returning Nested Deferred
};

client.join()

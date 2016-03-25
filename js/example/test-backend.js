var riffle = require('jsriffle');

riffle.setFabricLocal();
riffle.setLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.subdomain("backend");
var client = app.subdomain("client");

backend.onJoin = function() {
  // Example Test Client leave - does client leave properly
  this.register("testClientLeave", riffle.want(function(s) {
    console.log(s); // Expects a String, like "Leave"
    return "Leaving";
  }, String));
  // End Example Test Client leave

  // Example Test Backend leave - does client leave properly
  var self = this;
  this.onLeave = function() {
    console.log("On Leave Triggered"); // Expects a String, like "On Leave Triggered"
  };
  this.register("testBackendLeave", riffle.want(function(s) {
    self.leave();
    return "Leaving";
  }, String));
  // End Example Test Backend leave

  // Example Test Returning Nested Deferred - demonstrates returning nested deferreds
  this.register("testBackendNested", riffle.want(function(s) {
    return sender.call("testClientNested", s + ", second").then(function(a) {
      return a + ", fourth"
    });
  }, String));
  // End Example Test Returning Nested Deferred

};

backend.join()

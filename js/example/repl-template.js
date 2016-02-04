// Example REPL Template - The REPL code
// ARBITER set action template

var riffle = require('jsriffle');

riffle.SetFabricSandbox();

var app = riffle.Domain("xs.demo.test");
var backend = app.subdomain("backend");

backend.onJoin = function() {

    // Exis code goes here

};

backend.join()
// End Example REPL Template

var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.demo.test");
var backend = app.Subdomain("backend");
var client = app.Subdomain("client");


function test(){
  console.log(arguments);
  console.log(arguments[0].fullname());

  //TODO This doesn't actually every return to the caller
  return "String";
}


backend.onJoin = function() {

    this.Subscribe("basicSub", riffle.want(function(s) {
        console.log(s);
    }, String));
};


backend.Join()



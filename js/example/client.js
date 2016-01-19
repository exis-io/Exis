
var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.damouse");
var receiver = app.Subdomain("alpha");
var me = app.Subdomain("beta");

//Example Person Class
function Person(){
  this.first = String;
  this.last = String;
  this.age = Number;
}

Person.prototype.fullname = function(){
  return this.first + " " + this.last;
};

var nick = new Person();
nick.first = "Nick";
nick.last = "Hyatt";
nick.age = 101;

me.onJoin = function() {
    console.log("Sender Joined");

    receiver.Publish("sub", nick);

    receiver.Call("reg", {string: "this is a string!"}, [33, 22, 11]).then(function(results){
        console.log("Results: ", results);
    }, function(error) {
        console.log("Call failed with error: ", error);
    });
};

me.Join()

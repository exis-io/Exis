var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.damouse");
var me = app.Subdomain("alpha");

//Example Person Class
function Person(){
  this.first = String;
  this.last = String;
  this.age = Number;
}

Person.prototype.fullname = function(){
  return this.first + " " + this.last;
};

//TODO Notes:
//Nested Objects don't seem to work. 
//Objects nested in arrays don't seem to work.
//Objects with arbitrary keys don't seem to work
//Arrays with any type of elements don't work.
//Number types when represented to the go core as either 'float' or 'int' always succeed. So if specify Number type as 'int' but send 44.44 it still goes through.

function printName(p){
  console.log(p.fullname());
}

function log(obj, array){
  console.log(obj);
  console.log(array);
  return "Success";
}


me.onJoin = function() {
    console.log("Receiever Joined");

    var wantPerson = riffle.want(printName, riffle.ModelObject(Person));
    this.Subscribe("sub", wantPerson).then( function(args){ 
        console.log("Success with args:", args) 
    }, function(args){ 
         console.log("Error with args: ", args) 
    });

    this.Register("reg", riffle.want(log, {string: String}, [Number]));
};


me.Join()



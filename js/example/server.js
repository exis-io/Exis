var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.damouse");
var me = app.Subdomain("alpha");

/*Extra stuff for testing reconstruction of js classes from riffle models*/

function Person(){
  this.age = 47;
  this.race = "white";
}

Person.prototype.fullname = function(){
  return this.first + " " + this.last;
};

function Family(){
  this.name = "The Morgans";
}

Family.prototype.members = function(){
  var members = "";
  members += this.mom.fullname() + '\n';
  members += this.dad.fullname() + '\n';
  members += this.kid.fullname() + '\n';
  return members;
}

Person.prototype.fullname = function(){
  return this.first + " " + this.last;
};
var name = new riffle.ObjectWithKeys({first: String, last: String});
var person = new riffle.ObjectToClass(Person, name);
var array = new riffle.ArrayWithType(String);
//TODO Notes:
//Nested Objects don't seem to work. 
//Objects nested in arrays don't seem to work.
//Objects with arbitrary keys don't seem to work
//Arrays with any type of elements don't work.
//Subscribe handler gets all arguments handed in in an array as the only argument to the function vs Register handler which has arguments splatted
//Number types when represented to the go core as either 'float' or 'int' always succeed. So if specify Number type as 'int' but send 44.44 it still goes through.

function test(){
  console.log(arguments);
  console.log(arguments[0].fullname());

  //TODO This doesn't actually every return to the caller
  return "String";
}


me.onJoin = function() {
    console.log("Receiever Joined");


    var wantName = riffle.want(test, name);
    this.Subscribe("sub", wantName).then( function(args){ 
        console.log("Success with args:", args) 
    }, function(args){ 
         console.log("Error with args: ", args) 
    });

    var wantPerson = riffle.want(test, person);
    this.Register("reg", wantPerson);
};


me.Join()



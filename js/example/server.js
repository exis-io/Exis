
var riffle = require('jsriffle');

riffle.SetFabricLocal();
riffle.SetLogLevelDebug();

var app = riffle.Domain("xs.damouse");
var me = app.subdomain("alpha");

//Example Person Class
function Person(){
  this.first = String;
  this.last = String;
  this.age = Number;
}

Person.prototype.fullname = function(){
  return this.first + " " + this.last;
};

function printName(p){
  console.log("NAME: ", p.fullname());
}

function log(obj, array) {
  console.log("LOGGING")
  console.log(obj);
  console.log(array);
  return "Success";
}

me.onJoin = function() {
    console.log("Receiever Joined");

    // Example Tour Reg/Call Lesson 2 Wait Check - type enforcement on wait
    this.register("iGiveInts", riffle.want(function(s) {
        console.log(s); // Expects a String, like "Hi"
        return 42;
    }, String));
    // End Example Tour Reg/Call Lesson 2 Wait Check

};

me.join()


//TODO Notes:
// Nested Objects don't seem to work. 
// Objects nested in arrays don't seem to work.
// Objects with arbitrary keys don't seem to work
// Arrays with any type of elements don't work.
// Number types when represented to the go core as either 'float' or 'int' always succeed. So if specify Number type as 'int' but send 44.44 it still goes through.

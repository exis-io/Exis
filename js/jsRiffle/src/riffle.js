require('./go.js');
var want = require('./want.js');
var ws = require('./websocket.js');
var pjson = require('../package.json');
global.Q = require('q');

global.WsFactory = require('./websocket').Factory;

exports.want = want.want;
exports.modelObject = want.ModelObject;

exports.Domain = global.Domain.New;
exports.version = pjson.version;


// Used to counteract uint generation on seemlingly 32 bit platforms
global.NewID = function() {
  return Math.floor(Math.random() * 9007199254740992);
};

global.Renamer = function(domain) {
  for (var func in domain) {
    domain[func.substr(0, 1).toLowerCase() + func.substr(1)] = domain[func];
    delete domain[func];
  }
}

global.WantInterceptor = function(corePromise, typeCheck) {

  return function() {
    var wantDefer = global.Q.defer();
    var args = [];
    args.push(wantDefer.resolve);
    for (var i in arguments) {
      args.push(arguments[i]);
    }
    var callback = want.want.apply(this, args)

    function checkTypes() {
      var args = [];
      for (arg in arguments) {
        args.push(arguments[arg]);
      }
      var anotherDefer = global.Q.defer();
      typeCheck(callback.types, args, anotherDefer);
      anotherDefer.promise.then(callback.fp, wantDefer.reject);
    }
    corePromise.then(checkTypes, wantDefer.reject);
    return wantDefer.promise;
  };
}

// Takes a javascript promise and a go function. Assigns the go function as 
// the then for the crust promise.
// TODO: catch errors!
global.NestedInterceptor = function(crustPromise, completeYield) {
  crustPromise.then(completeYield)
}

// Inject configuration functions from the mantle into the crust with the same name
for (var e in global.Config) {
  exports[e] = global.Config[e];
}

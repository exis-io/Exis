
require('./go.js');
var want = require('./want.js');
var ws = require('./websocket.js');
var pjson = require('../package.json');

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

// Intercepts .then and sends down cumin args to the core. 
// Should only be used by Calls, and internally at that 
global.PromiseInterceptor = function(trueHandler, domain, cb) {
    return function(callback, errback) {
        // Automatically splat the arguments across the callback function 
        var applyer = function(fn) {
            return function(a) {  fn.apply(domain, a) }
        };

        // If callback has these two properties, then its NOT a callback, its a wait
        if (callback.types == undefined && callback.fb == undefined) {
            domain.callExpects(cb, [null]);
            trueHandler(applyer(callback), errback)
        } else {
            domain.callExpects(cb, callback.types);
            trueHandler(applyer(callback.fp), errback);
        }
    }
}

global.WaitInterceptor = function(trueHandler, domain, cb) {

    var t = global.PromiseInterceptor(trueHandler, domain, cb);

    return function(){
        var types = [];
        for(var arg in arguments){
          types.push(arguments[arg]);
        }

        function then(){
          var args = [];
          for(var i in arguments){
            args.push(arguments[i]);
          }
          types.unshift(arguments[0]);
          console.log(types);
          args[0] = want.want.apply(this, types);
          console.log(args)
          t.apply(this, args);
        }
    
        return {
          then: then
        };
    };
}

// Inject configuration functions from the mantle into the crust with the same name
for (var e in global.Config) {
    exports[e] = global.Config[e];
}


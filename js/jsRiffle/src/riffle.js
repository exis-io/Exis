
require('./go.js');
var want = require('./want.js');
var ws = require('./websocket.js');
var pjson = require('../package.json');

global.WsFactory = require('./websocket').Factory;
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
        // If callback has these two properties, then its NOT a callback, its a wait
        if (callback.types == undefined && callback.fb == undefined) {

            // splat the arguments across the callback function
            var applyer = function(callbackArgs) {
                callback.apply(domain, callbackArgs);
            };

            domain.callExpects(cb, [null]);
            trueHandler(applyer, errback)
        } else {
            domain.callExpects(cb, callback.types);
            trueHandler(callback.fp, errback);
        }
    }
}

exports.Domain = global.Domain.New;

exports.setLogLevelOff = global.Config.SetLogLevelOff;
exports.setLogLevelApp = global.Config.SetLogLevelApp;
exports.setLogLevelErr = global.Config.SetLogLevelErr;
exports.setLogLevelWarn = global.Config.SetLogLevelWarn;
exports.setLogLevelInfo = global.Config.SetLogLevelInfo;
exports.setLogLevelDebug = global.Config.SetLogLevelDebug;

exports.setFabricDev = global.Config.SetFabricDev;
exports.setFabricSandbox = global.Config.SetFabricSandbox;
exports.setFabricProduction = global.Config.SetFabricProduction;
exports.setFabricLocal = global.Config.SetFabricLocal;
exports.setFabric = global.Config.SetFabric;

exports.application = global.Config.Application;
exports.debug = global.Config.Debug;
exports.info = global.Config.Info;
exports.warn = global.Config.Warn;
exports.error = global.Config.Error;

exports.want = want.want;
exports.wait = want.wait;
exports.ModelObject = want.ModelObject;


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
global.PromiseInterceptor = function(trueHandler, domain, cb, other) {
    return function(waitProcessor, trueErrback) {
        domain.callExpects(cb, waitProcessor.types);
        trueHandler(waitProcessor.fp, trueErrback)
    }
}

exports.Domain = global.Domain.New;

exports.SetLogLevelOff = global.Config.SetLogLevelOff;
exports.SetLogLevelApp = global.Config.SetLogLevelApp;
exports.SetLogLevelErr = global.Config.SetLogLevelErr;
exports.SetLogLevelWarn = global.Config.SetLogLevelWarn;
exports.SetLogLevelInfo = global.Config.SetLogLevelInfo;
exports.SetLogLevelDebug = global.Config.SetLogLevelDebug;

exports.SetFabricDev = global.Config.SetFabricDev;
exports.SetFabricSandbox = global.Config.SetFabricSandbox;
exports.SetFabricProduction = global.Config.SetFabricProduction;
exports.SetFabricLocal = global.Config.SetFabricLocal;
exports.SetFabric = global.Config.SetFabric;

exports.Application = global.Config.Application;
exports.Debug = global.Config.Debug;
exports.Info = global.Config.Info;
exports.Warn = global.Config.Warn;
exports.Error = global.Config.Error;

exports.want = want.want;
exports.wait = want.wait;
exports.ModelObject = want.ModelObject;

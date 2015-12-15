

require('./polyfill.js');

var log = require('./log.js');
var pjson = require('../package.json');
var when = require('when');
var fn = require("when/function");
var configure = require('./configure.js');

exports.version = pjson.version;
exports.transports = configure.transports;
exports.when = when;
exports.log = log;


//
// Begin GOJS implementation
//

var go = require('./go.js');
var ws = require('./transport/websocket.js');


// Dont need any of this-- just return the conn
var Ws = function () {
    this.open = function(url) {
        // Methods available on the conn: console.log, protocol, send, close, onmessage, onopen, onclose, info
        var factory = new ws.Factory({'type': 'websocket', 'url': url});
        this.conn = factory.create();
        this.conn.onmessage = this.onmessage;
        this.conn.onopen = this.onopen;
        this.conn.onclose = this.onclose;
    }
}; 

global.WsWrapper = new Ws();

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
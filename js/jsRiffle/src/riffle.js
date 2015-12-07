///////////////////////////////////////////////////////////////////////////////
//
//  AutobahnJS - http://autobahn.ws, http://wamp.ws
//
//  A JavaScript library for WAMP ("The Web Application Messaging Protocol").
//
//  Copyright (C) 2011-2014 Tavendo GmbH, http://tavendo.com
//
//  Licensed under the MIT License.
//  http://www.opensource.org/licenses/mit-license.php
//
///////////////////////////////////////////////////////////////////////////////


// Polyfills for <= IE9
require('./polyfill.js');

var pjson = require('../package.json');

var when = require('when');
//var fn = require("when/function");

if ('RIFFLE_DEBUG' in global && RIFFLE_DEBUG) {
   // https://github.com/cujojs/when/blob/master/docs/api.md#whenmonitor
   require('when/monitor/console');
   if ('console' in global) {
      console.log("Riffle debug enabled");
   }
}

var util = require('./util.js');
var log = require('./log.js');
var session = require('./session.js');
var connection = require('./connection.js');
var configure = require('./configure.js');

var persona = require('./auth/persona.js');
var cra = require('./auth/cra.js');

exports.version = pjson.version;

exports.transports = configure.transports;

exports.Connection = connection.Connection;


exports.Session = session.Session;
exports.Invocation = session.Invocation;
exports.Event = session.Event;
exports.Result = session.Result;
exports.Error = session.Error;
exports.Subscription = session.Subscription;
exports.Registration = session.Registration;
exports.Publication = session.Publication;

exports.auth_persona = persona.auth;
exports.auth_cra = cra;

exports.when = when;

exports.util = util;
exports.log = log;

// Global configuration

//
// Begin GOJS implementation
//

var go = require('./go.js');
var ws = require('./transport/websocket.js');

FABRIC_URL = "ws://localhost:8000/ws";

var Ws = function () {
    self = this;

    // console.log("Connection created")
    // var connection = new riffle.Connection("Dont need a domain");
    
    // console.log(connection._transport_factories)
    // this.conn = connection._create_transport()

    // Theres also a transport.send(msg)
    this.onmessage = function(message) {
        consloe.log("DEFAULT message handler");
    };


    this.open = function() {
        // console.log(transport);
        // protocol: undefined,
        // send: [Function],
        // close: [Function],
        // onmessage: [Function],
        // onopen: [Function],
        // onclose: [Function],
        // info: { type: 'websocket', url: null, protocol: 'wamp.2.json' } }

        var factory = new ws.Factory({'type': 'websocket', 'url': FABRIC_URL});
        self.conn = factory.create();

        // console.log(self.conn);

        this.conn.onmessage = function(message) {
            console.log("DEFAULT Message received: ", message);

            if (self.onmessage) {
                self.onmessage(message)
            }
        };

        this.conn.onopen = function() {
            // console.log("DEFAULT Transport opened");
            global.Wrapper.ConnectionOpened();
        };

        this.conn.onclose = function() {
            console.log("DEFAULT Transport closed");
        };

        // self.transport = self.conn.create();
    }
}; 


Ws.prototype.send = function(message) {
    console.log("Sending message: ", message)
    this.conn.send(message);
};

Ws.prototype.close = function(code, reason) {
    console.log("Closing connection with reason: ", reason)
    this.conn.close(code, reason)
};



global.Wrapper.New();
console.log("Created wrapper");

// 
// This is the best way to get the socket to open, but not sure how to let it happen
// 

var conn = new Ws();
conn.open()

global.Wrapper.SetConnection(conn);
// console.log("Opened a connection");

// var domain = new global.wrapper.NewDomain("xs.damouse.js.alpha")
var domain = global.Domain.New("xs.damouse.js.alpha")
console.log("Created domain");


domain.Join()

// domain.Subscribe("sub", function() {
//     console.log("Received a publish!")
// })

// domain.Register("ret", function() {
//     console.log("Received a call!")
// })

// domain.Run()
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
FABRIC_URL = "ws://localhost:8000/ws";

// TODO: fabric url doesn't set without calling this method 
exports.setDevFabric = function(url) {
    FABRIC_URL = 'ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws';
};

//
// Begin GOJS implementation
//

var go = require('./go.js');

var pet = global.pet.New("Fido");
console.log("Pet: ", pet);


exports.Domain = connection.Domain;
// exports.Conn = connection.CoreConn;

// global.wrapper.HelloWorld("JS: This function is called from riffle.js")
exports.HelloWorld = global.wrapper.HelloWorld;


console.log("Opening a connection");
var conn = new connection.CoreConn();

// var domain = new global.wrapper.NewDomain("xs.damouse.js.alpha")
var domain = global.Dom.NewDomain("xs.damouse.js.alpha")
console.log("Created domain: ", domain);

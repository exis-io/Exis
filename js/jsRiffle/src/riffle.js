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
exports.Domain = connection.Domain;

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

var go = require('./go.js');

exports.domain = global.core.Domain("xs.damouse")

// global.core.Receiver("Hello from js!");
// global.core.Pure('ws://ubuntu@ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws', 'xs.damouse.awwyea');

// "Network access is not supported by gopherjs"
// global.core.Native('ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws', 'xs.damouse.awwyeah');

// Global configuration
FABRIC_URL = "node.exis.io";

// TODO: fabric url doesn't set without calling this method 

exports.setDevFabric = function(url) {
  
    FABRIC_URL = 'ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws';

    // Turn on debug logging, too
    // exports.debug = function () {
    //     console.log.apply(console, arguments);
    // };
};

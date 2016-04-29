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


var util = require('../util.js');


function Factory (options) {
   var self = this;

   util.assert(options.url !== undefined, "options.url missing");
   util.assert(typeof options.url === "string", "options.url must be a string");

   if (!options.protocols) {
      options.protocols = ['wamp.2.json'];
   } else {
      util.assert(Array.isArray(options.protocols), "options.protocols must be an array");
   }

   self._options = options;
}


Factory.prototype.type = "websocket";


Factory.prototype.create = function () {

   var self = this;

   // the WAMP transport we create
   var transport = {};

   // these will get defined further below
   transport.protocol = undefined;
   transport.send = undefined;
   transport.close = undefined;

   // these will get overridden by the WAMP session using this transport
   transport.onmessage = function () {};
   transport.onopen = function () {};
   transport.onclose = function () {};

   transport.info = {
      type: 'websocket',
      url: null,
      protocol: 'wamp.2.json'
   };

   // running in Node.js

   var WebSocket = require('ws'); // https://github.com/einaros/ws
   var websocket;

   var protocols;
   if (self._options.protocols) {
      protocols = self._options.protocols;
      if (Array.isArray(protocols)) {
         protocols = protocols.join(',');
      }
      websocket = new WebSocket(self._options.url, {protocol: protocols});
   } else {
      websocket = new WebSocket(self._options.url);
   }

   transport.send = function (msg) {
      websocket.send(msg, {binary: false});
   };

   transport.close = function (code, reason) {
      websocket.close();
   };

   websocket.on('open', function () {
      transport.onopen();
   });

   websocket.on('message', function (data, flags) {
      if (flags.binary) {
         // FIXME!
      } else {
          // console.log("Node WS receive: ", data)
         // var msg = JSON.parse(data);
         transport.onmessage(data);
      }
   });

   // FIXME: improve mapping to WS API for the following
   // https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent#Close_codes
   //
   websocket.on('close', function (code, message) {
      var details = {
         code: code,
         reason: message,
         wasClean: code === 1000
      }
      transport.onclose(details);
   });

   websocket.on('error', function (error) {
      var details = {
         code: 1006,
         reason: '',
         wasClean: false
      }
      transport.onclose(details);
   });

   return transport;
};



exports.Factory = Factory;

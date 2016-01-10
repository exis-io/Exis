///////////////////////////////////////////////////////////////////////////////
//
//  Arbiter
//  A helper package for Exis documentation and testing.
//
//  Copyright (C) 2015-2016 Exis
//
///////////////////////////////////////////////////////////////////////////////

var render = require("./render");
var g = require("./generator");

var lang = g.JS;
//var lang = g.Python;

////////////////////////////////////////////////////////////
// Register
var reqReg = new render.Request();
reqReg.action = "register";
reqReg.endpoint = "basicReg";
reqReg.want = ["str:s", "int:i"];
reqReg.returns = ["Hello World", 0.1];

var l = new lang(reqReg);
console.log(l.generate());

//render.Render(reqReg);
console.log('---------------------------------------------------------');

////////////////////////////////////////////////////////////
// Subscribe
var reqSub = new render.Request();
reqSub.action = "subscribe";
reqSub.endpoint = "basicSub";
reqSub.want = ["str:s", "int:i"];

var l = new lang(reqSub);
console.log(l.generate());

console.log('---------------------------------------------------------');

////////////////////////////////////////////////////////////
// Publish
var reqPub = new render.Request();
reqPub.action = "publish";
reqPub.endpoint = "basicSub";
reqPub.args = ["Hello World", 0];

var l = new lang(reqPub);
console.log(l.generate());
console.log('---------------------------------------------------------');

////////////////////////////////////////////////////////////
// Call
var reqCall = new render.Request();
reqCall.action = "call";
reqCall.endpoint = "basicReg";
reqCall.args = ["Hi", 3];
reqCall.wait = ["str:s", "int:i"];

var l = new lang(reqCall);
console.log(l.generate());

console.log('---------------------------------------------------------');

///////////////////////////////////////////////////////////////////////////////
//
//  Arbiter
//  A helper package for Exis documentation and testing.
//
//  Copyright (C) 2015-2016 Exis
//
///////////////////////////////////////////////////////////////////////////////

var g = require("./generator");

////////////////////////////////////////////////////////////
// Register
var reqReg = new g.Request();
reqReg.action = "register";
reqReg.endpoint = "basicReg";
reqReg.want = ["str:s", "int:i"];
reqReg.returns = ["Hello World", 0.1];
reqReg.setup();

g.Render(reqReg);
console.log('---------------------------------------------------------');

////////////////////////////////////////////////////////////
// Subscribe
var reqSub = new g.Request();
reqSub.action = "subscribe";
reqSub.endpoint = "basicSub";
reqSub.want = ["str:s", "int:i"];
reqSub.setup();

g.Render(reqSub);
console.log('---------------------------------------------------------');

////////////////////////////////////////////////////////////
// Publish
var reqPub = new g.Request();
reqPub.action = "publish";
reqPub.endpoint = "basicSub";
reqPub.args = ["Hello World", 0];
reqPub.setup();

g.Render(reqPub);
console.log('---------------------------------------------------------');

////////////////////////////////////////////////////////////
// Call
var reqCall = new g.Request();
reqCall.action = "call";
reqCall.endpoint = "basicReg";
reqCall.args = ["Hi", 3];
reqCall.wait = ["str:s", "int:i"];
reqCall.setup();

g.Render(reqCall);
console.log('---------------------------------------------------------');

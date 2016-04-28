///////////////////////////////////////////////////////////////////////////////
//
//  jsRiffle - http://exis.io, 
//
//
///////////////////////////////////////////////////////////////////////////////

//For building the browser versions to avoid bloating with unneccessary libs
global.WsFactory = require('./browsersocket').Factory;
global.xsOverHTTP = require('./xsBrowserHttp')
module.exports = require('../riffle');

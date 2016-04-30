module.exports = xsReplay;
/**
 * @memberof jsRiffle
 * @function xsReplay
 * @param {RiffleDomain} domain - A valid {@link RiffleDomain} that represents the {@link /docs/appliances/Replay Replay} appliance.
 * @description Creates a new {@link Replay} class using the given properly formed {@link RiffleDomain}.
 * @returns {Replay} A new Replay object that can be used for interacting with a {@link /docs/appliances/Replay Replay} Appliance.
 * @example
 * //**Replay Example**
 * //create a domain for your app
 * var app = jsRiffle.Domain('xs.demo.dev.app');
 *
 * //create a Replay instance from the proper Replay subdomain of your app
 * var replay = jsRiffle.xsReplay(app.subdomain('Replay'));
 *
 * app.onJoin = function(){
 *   //add a replay listener on the channel
 *   replay.addReplay('xs.demo.dev.app.user/notifications').then(success, error);  
 * }
 *
 * app.join();
 */

function xsReplay(domain){
  return new Replay(domain);
}

/**
 * @typedef Replay
 * @description The Replay class provides an API for interacting with an {@link /docs/appliances/Replay Replay} Appliance
 * @see {@link /docs/appliances/Replay here} for documentation.
 * @example
 * **Query a Replay Channel**
 * //create a Replay instance from the domain
 * var replay = jsRiffle.xsReplay(app.subdomain('Replay'));
 *
 * //get messages published to a channel between startts and stopts (seconds from epoch)
 * replay.getReplay('xs.demo.dev.app/messages', startts, stopts).then(handler, error);
 */

function Replay(domain){
  this.conn = domain;
}

function makeCall(func, args){
  var args = Array.prototype.slice.call(args);
  args.unshift(func);
  return this.conn.call.apply(this.conn, args);
}

Replay.prototype.addReplay = function(){
  return makeCall.bind(this, 'addReplay', arguments)();
};

Replay.prototype.removeReplay = function(){
  return makeCall.bind(this, 'removeReplay', arguments)();
};

Replay.prototype.pauseReplay = function(){
  return makeCall.bind(this, 'pauseReplay', arguments)();
};

Replay.prototype.getReplay = function(){
  return makeCall.bind(this, 'getReplay', arguments)();
};


/*
for(var fnc in Replay.prototype){
  docsForAppliance('Replay', fnc);
}
*/

function docsForAppliance(name, fnc){
    var c = "";
    c += '/**\n';
    c += ' * @memberof '+name+'\n';
    c += ' * @function ' + fnc + '\n';
    c += ' * @see {@link /docs/appliances/'+name+'#'+fnc+' here} for documentation.\n'
    c += ' * @example\n';
    c += ' * '+name.toLowerCase()+'.'+fnc+'(...args).then(success, error);\n';
    c += ' */\n'
   console.log(c);
}

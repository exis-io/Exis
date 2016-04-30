module.exports = xsBouncer;
/**
 * @memberof jsRiffle
 * @function xsBouncer
 * @param {RiffleDomain} domain - A valid {@link RiffleDomain} 
 * @description Creates a new {@link Bouncer} class using the given properly formed {@link RiffleDomain}.
 * @returns {Bouncer} A new Bouncer object that can be used for interacting with a {@link /docs/appliances/Bouncer Bouncer} Appliance.
 * @example
 * //**Bouncer Example**
 * //create a domain
 * var app = jsRiffle.Domain('xs.demo.dev.app');
 *
 * //create a Bouncer instance from the domain
 * var bouncer = jsRiffle.xsBouncer(app);
 *
 * app.onJoin = function(){
 *   //assign a user to the user role for the app
 *   bouncer.assignRole('user', app.getName(), 'xs.demo.dev.app.username' ).then(success, error);  
 * }
 *
 * app.join();
 */

function xsBouncer(domain){
  return new Bouncer(domain);
}

/**
 * @typedef Bouncer
 * @description The Bouncer class provides an API for interacting with the {@link /docs/appliances/Bouncer Bouncer} Appliance
 * @see {@link /docs/appliances/Bouncer here} for documentation.
 * @example
 * **Creating a Static Role**
 * //create a Bouncer instance from the domain
 * var bouncer = jsRiffle.xsBouncer(app);
 *
 * //create a static role
 * bouncer.addStaticRole('admin', app.getName());
 */

function Bouncer(domain){
  this.conn = domain.linkDomain('xs.demo.Bouncer');
}

function makeCall(func, args){
  var args = Array.prototype.slice.call(args);
  args.unshift(func);
  return this.conn.call.apply(this.conn, args);
}

Bouncer.prototype.addDevModeDomain = function(){
  return makeCall.bind(this, 'addDevModeDomain', arguments)();
};

Bouncer.prototype.addDynamicRole = function(){
  return makeCall.bind(this, 'addDynamicRole', arguments)();
};

Bouncer.prototype.addSpecialAgent = function(){
  return makeCall.bind(this, 'addSpecialAgent', arguments)();
};

Bouncer.prototype.addStaticRole = function(){
  return makeCall.bind(this, 'addStaticRole', arguments)();
};

Bouncer.prototype.assignDynamicRole = function(){
  return makeCall.bind(this, 'assigneDynamicRole', arguments)();
};

Bouncer.prototype.assignRole = function(){
  return makeCall.bind(this, 'assignRole', arguments)();
};

Bouncer.prototype.checkPerm = function(){
  return makeCall.bind(this, 'checkPerm', arguments)();
};

Bouncer.prototype.delDynamicRole = function(){
  return makeCall.bind(this, 'delDynamicRole', arguments)();
};

Bouncer.prototype.destroyRole = function(){
  return makeCall.bind(this, 'destroyRole', arguments)();
};

Bouncer.prototype.inDevModeStatus = function(){
  return makeCall.bind(this, 'inDevModeStatus', arguments)();
};

Bouncer.prototype.listMembers = function(){
  return makeCall.bind(this, 'listMembers', arguments)();
};

Bouncer.prototype.listRoles = function(){
  return makeCall.bind(this, 'listRoles', arguments)();
};

Bouncer.prototype.listSpecialAgents = function(){
  return makeCall.bind(this, 'listSpecialAgents', arguments)();
};

Bouncer.prototype.newDynamicRole = function(){
  return makeCall.bind(this, 'newDynamicRole', arguments)();
};

Bouncer.prototype.removeApp = function(){
  return makeCall.bind(this, 'removeApp', arguments)();
};

Bouncer.prototype.removeDevModeDomain = function(){
  return makeCall.bind(this, 'removeDevModeDomain', arguments)();
};

Bouncer.prototype.removeSpecialAgent = function(){
  return makeCall.bind(this, 'removeSpecialAgent', arguments)();
};

Bouncer.prototype.revokeDynamicRole = function(){
  return makeCall.bind(this, 'revokeDynamicRole', arguments)();
};

Bouncer.prototype.revokePerm = function(){
  return makeCall.bind(this, 'revokePerm', arguments)();
};

Bouncer.prototype.revokeRole = function(){
  return makeCall.bind(this, 'revokeRole', arguments)();
};

Bouncer.prototype.setPerm = function(){
  return makeCall.bind(this, 'setPerm', arguments)();
};

/*
for(var fnc in Bouncer.prototype){
  docsForAppliance('Bouncer', fnc);
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

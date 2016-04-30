module.exports = xsAuth;
/**
 * @memberof jsRiffle
 * @function xsAuth
 * @param {RiffleDomain} domain - A valid {@link RiffleDomain} that represents the {@link /docs/appliances/Auth Auth} appliance.
 * @description Creates a new {@link Auth} class using the given properly formed {@link RiffleDomain}.
 * @returns {Auth} A new Auth object that can be used for interacting with a {@link /docs/appliances/Auth Auth} Appliance.
 * @example
 * //**Auth Example**
 * //create a domain for your app
 * var app = jsRiffle.Domain('xs.demo.dev.app');
 *
 * //create a Auth instance from the proper Auth subdomain of your app
 * var auth = jsRiffle.xsAuth(app.subdomain('Auth'));
 *
 * app.onJoin = function(){
 *   //get the number of users registered for your app
 *   auth.user_count().then(success, error);  
 * }
 *
 * app.join();
 */

function xsAuth(domain){
  return new Auth(domain);
}

/**
 * @typedef Auth
 * @description The Auth class provides an API for interacting with an {@link /docs/appliances/Auth Auth} Appliance
 * @see {@link /docs/appliances/Auth here} for documentation.
 * @example
 * **Query Auth Users**
 * //create a Auth instance from the domain
 * var auth = jsRiffle.xsAuth(app.subdomain('Auth'));
 *
 * //get data about users(email, name, etc.)
 * auth.get_users().then(handler, error);
 */

function Auth(domain){
  this.conn = domain;
}

function makeCall(func, args){
  var args = Array.prototype.slice.call(args);
  args.unshift(func);
  return this.conn.call.apply(this.conn, args);
}

Auth.prototype.delete_custom_token = function(){
  return makeCall.bind(this, 'delete_custom_token', arguments)();
};

Auth.prototype.gen_custom_token = function(){
  return makeCall.bind(this, 'gen_custom_token', arguments)();
};

Auth.prototype.get_custom_token = function(){
  return makeCall.bind(this, 'get_custom_token', arguments)();
};

Auth.prototype.get_private_data = function(){
  return makeCall.bind(this, 'get_private_data', arguments)();
};

Auth.prototype.get_public_data = function(){
  return makeCall.bind(this, 'get_public_data', arguments)();
};

Auth.prototype.get_users = function(){
  return makeCall.bind(this, 'get_users', arguments)();
};

Auth.prototype.get_user_data = function(){
  return makeCall.bind(this, 'get_user_data', arguments)();
};

Auth.prototype.list_custom_tokens = function(){
  return makeCall.bind(this, 'list_custom_tokens', arguments)();
};

Auth.prototype.save_user_data = function(){
  return makeCall.bind(this, 'save_user_data', arguments)();
};

Auth.prototype.user_count = function(){
  return makeCall.bind(this, 'user_count', arguments)();
};

/*
for(var fnc in Auth.prototype){
  docsForAppliance('Auth', fnc);
}
*/

function docsForAppliance(name, fnc){
    var c = "";
    c += '/**\n';
    c += ' * @memberof '+name+'\n';
    c += ' * @function ' + fnc + '\n';
    c += ' * @see {@link /docs/appliances/'+name+'#'+fnc+ ' here} for documentation.\n'
    c += ' * @example\n';
    c += ' * '+name.toLowerCase()+'.'+fnc+'(...args).then(success, error);\n';
    c += ' */\n'
   console.log(c);
}

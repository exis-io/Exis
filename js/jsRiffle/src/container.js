module.exports = xsContainers;
/**
 * @memberof jsRiffle
 * @function xsContainers
 * @param {RiffleDomain} domain - A valid {@link RiffleDomain} that represents the {@link /docs/appliances/Container Container} appliance.
 * @description Creates a new {@link Container} class using the given properly formed {@link RiffleDomain}.
 * @returns {Container} A new Container object that can be used for interacting with a {@link /docs/appliances/Container Container} Appliance.
 * @example
 * //**Container Example**
 * //create a domain for your app
 * var app = jsRiffle.Domain('xs.demo.dev.app');
 *
 * //create a Container instance from the proper Container subdomain of your app
 * var container = jsRiffle.xsContainers(app.subdomain('Container'));
 *
 * app.onJoin = function(){
 *   //list the container in the appliance
 *   container.list().then(success, error);  
 * }
 *
 * app.join();
 */

function xsContainers(domain){
  return new Container(domain);
}

/**
 * @typedef Container
 * @description The Container class provides an API for interacting with an {@link /docs/appliances/Container Container} Appliance
 * @see {@link /docs/appliances/Container here} for documentation.
 * @example
 * **Inspect a Container**
 * //create a Container instance from the domain
 * var auth = jsRiffle.xsContainers(app.subdomain('Container'));
 *
 * //get data about users(email, name, etc.)
 * auth.get_users().then(handler, error);
 */

function Container(domain){
  this.conn = domain;
}

function makeCall(func, args){
  var args = Array.prototype.slice.call(args);
  args.unshift(func);
  return this.conn.call.apply(this.conn, args);
}

Container.prototype.build = function(){
  return makeCall.bind(this, 'build', arguments)();
};

Container.prototype.create = function(){
  return makeCall.bind(this, 'create', arguments)();
};

Container.prototype.list = function(){
  return makeCall.bind(this, 'list', arguments)();
};

Container.prototype.images = function(){
  return makeCall.bind(this, 'images', arguments)();
};

Container.prototype.remove = function(){
  return makeCall.bind(this, 'remove', arguments)();
};

Container.prototype.removeImage = function(){
  return makeCall.bind(this, 'removeImage', arguments)();
};

Container.prototype.updateImage = function(){
  return makeCall.bind(this, 'updateImage', arguments)();
};

Container.prototype.image = function(name){
  return makeCall.bind(this, name+'/image',[])();
};

Container.prototype.inspect = function(name){
  return makeCall.bind(this, name+'/inspect', [])();
};

Container.prototype.logs = function(name){
  return makeCall.bind(this, name+'/logs', [])();
};

Container.prototype.restart = function(name){
  return makeCall.bind(this, name+'/restart', [])();
};

Container.prototype.start = function(name){
  return makeCall.bind(this, name+'/start', [])();
};

Container.prototype.stop = function(name){
  return makeCall.bind(this, name+'/stop', [])();
};

Container.prototype.top = function(name){
  return makeCall.bind(this, name+'/top', [])();
};

for(var fnc in Container.prototype){
  //docsForAppliance('Container', fnc);
}

function docsForAppliance(name, fnc){
    var c = "";
    c += '/**\n';
    c += ' * @memberof '+name+'\n';
    c += ' * @function ' + fnc + '\n';
    c += ' * @see {@link /docs/appliances/'+name+' here} for documentation.\n'
    c += ' * @example\n';
    c += ' * '+name.toLowerCase()+'.'+fnc+'(...args).then(success, error);\n';
    c += ' */\n'
   console.log(c);
}

module.exports = xsFileStorage;
/**
 * @memberof jsRiffle
 * @function xsFileStorage
 * @param {RiffleDomain} domain - A valid {@link RiffleDomain} for the app/user.
 * @description Creates a new {@link FileStorage} class using the given properly formed {@link RiffleDomain}.
 * @returns {FileStorage} A new FileStorage object that can be used for interacting with Exis' Cloud FileStorage system.
 * @example
 * //**FileStorage Example**
 * //create a domain representing your developer account
 * var me = jsRiffle.Domain('xs.demo.dev');
 *
 * //create a FileStorage instance using the domain
 * var filestorage = jsRiffle.xsFileStorage(me);
 *
 * me.onJoin = function(){
 *   //#TODO: Make an upload example
 *   auth.user_count().then(success, error);  
 * }
 *
 * app.join();
 */

function xsFileStorage(domain){
  return new FileStorage(domain);
}

/**
 * @typedef FileStorage
 * @description The FileStorage class provides an API for interacting with Exis' Cloud FileStorage system
 * @example
 * **List info about files and collections in a directory**
 * //create a FileStorage instance from the domain
 * var filestorage = jsRiffle.xsFileStorage(me);
 *
 * //get info about the contents of the directory
 * filestorage.listCollection('app/public/').then(handler, error);
 * //handler recieves an object describing the contents of the form below
 * {
 *   files: [
 *     {
 *       modified: string, //ISO timestamp last modified for the file
 *       name: string, //The filename as assigned by dev
 *       path: string, //The path of the file
 *       url: string, //A url that can be used to get the file
 *     }, ...
 *   ],
 *   collections: [
 *     {
 *       name: string, //The name of the collection
 *       path: string, //The path at which the file resides
 *     }
 *   ]
 * }
 */

function FileStorage(domain){
  this.conn = domain.linkDomain('xs.demo.FileStorage');
}

function makeCall(func, args){
  var args = Array.prototype.slice.call(args);
  args.unshift(func);
  return this.conn.call.apply(this.conn, args);
}

FileStorage.prototype.uploadUserFile = function(){
  return makeCall.bind(this, 'uploadUserFile', arguments)(); //TODO: Handle Post Request
};

FileStorage.prototype.uploadFile = function(){
  return makeCall.bind(this, 'uploadFile', arguments)(); //TODO: Handle Post Request
};

FileStorage.prototype.deleteUserFile = function(){
  return makeCall.bind(this, 'deleteUserFile', arguments)();
};

FileStorage.prototype.deleteFile = function(){
  return makeCall.bind(this, 'deleteFile', arguments)();
};

FileStorage.prototype.deleteUserCollection = function(){
  return makeCall.bind(this, 'deleteUserCollection', arguments)();
};

FileStorage.prototype.deleteCollection = function(){
  return makeCall.bind(this, 'deleteCollection', arguments)();
};

FileStorage.prototype.getUserFile = function(){
  return makeCall.bind(this, 'getUserFile', arguments)();
};

FileStorage.prototype.getFile = function(){
  return makeCall.bind(this, 'getFile', arguments)();
};

FileStorage.prototype.deleteUserCollection = function(){
  return makeCall.bind(this, 'listUserCollection', arguments)();
};

FileStorage.prototype.deleteCollection = function(){
  return makeCall.bind(this, 'listCollection', arguments)();
};


for(var fnc in FileStorage.prototype){
  //docsForAppliance('FileStorage', fnc);
}

function docsForAppliance(name, fnc){
    var c = "";
    c += '/**\n';
    c += ' * @memberof '+name+'\n';
    c += ' * @function ' + fnc + '\n';
    c += ' * @desctription  TODO' + fnc + '\n';
    c += ' * @example  TODO' + fnc + '\n';
    c += ' */\n'
   console.log(c);
}

module.exports = xsFileStorage;
/**
 * @memberof jsRiffle
 * @function xsFileStorage
 * @param {RiffleDomain} domain - A valid {@link RiffleDomain} for the developer/user.
 * @description Creates a new {@link FileStorage} class using the given properly formed {@link RiffleDomain}.
 * @returns {FileStorage} A new FileStorage object that can be used for interacting with Exis' Cloud FileStorage system.
 * @example
 * //**Upload a File**
 * //create a domain representing your developer account
 * var me = jsRiffle.Domain('xs.demo.dev');
 *
 * //create a FileStorage instance using the domain
 * var filestorage = jsRiffle.xsFileStorage(me);
 *
 * me.onJoin = function(){
 *   //upload a file to the location of path in myapp's Cloud FileStorage
 *   //Node.JS
 *   filestorage.uploadFile({file: "/path/to/file", path: 'myapp/myfile.txt'}).then(success, error);  
 *   //Browser (file is a file object)
 *   filestorage.uploadFile({file: file, path: 'myapp/myfile.txt'}).then(success, error, progress);  
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
 * **Listing files in FileStorage Service**
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

/**
 * @memberof FileStorage
 * @function uploadUserFile
 * @description Upload a file to the user's collection. This function only works for users or Containers of a registered app.
 * @param {object} details - An object containing the details and the file to upload.
 * @param {string | File} details.file  - The path to the file in Node.JS the File object in the Browser.
 * @param {string} details.name - The name to save the file to when it is uploaded.
 * @param {string=} user.collection - The collection or path to store the file to. Defaults to 'uploads'.
 * @param {boolean=} details.correctOrientation - **Browser Only** This will attempt to correct an images orientation based
 * on the EXIF Orientation data if any is present on the image. If no orientation is detected, or the file is not an image,
 * or the platform doesn't support the implementation then the file will be uploaded as is.
 * @example
 * //create a domain representing a user of you app
 * var user = jsRiffle.Domain('xs.demo.dev.myapp.user');
 *
 * //create a FileStorage instance using the domain
 * var filestorage = jsRiffle.xsFileStorage(user);
 *
 * user.onJoin = function(){
 *   //upload the user's profile.jpg to their 'photos' collection in Cloud FileStorage
 *   //Node.JS
 *   filestorage.uploadFile({file: "/path/to/file", name: 'profile.jpg', collection: 'photos'}).then(success, error);  
 *   //Browser (file is a file object)
 *   filestorage.uploadFile({file: file, name: 'profile.jpg', collection: 'photos'}).then(success, error, progress); //progess will recieve calls during upload with the percentage complete.
 * }
 *
 * app.join();
 */

FileStorage.prototype.uploadUserFile = function(details){
  if(!details || !details.name || !details.file){
    throw "Error: Improper arguments.";
  }
  details.collection = details.collection || 'uploads';
  //on node
  if(global.process && global.process.versions.node){
    return global.xsOverHTTP.uploadUserFile(details.file, details.name, details.collection, this.conn);
  }else{
    var correct = details.correctOrientation || false;
    return this.conn.call('uploadUserFile', details.name, details.file.type, details.collection).then(global.xsOverHTTP.uploadFile.bind({}, details.file, correct));
  }
};

/**
 * @memberof FileStorage
 * @function uploadFile
 * @description Upload a file to a registered app's FileStorage. This function only works for developers.
 * @param {object} details - An object containing the details and the file to upload.
 * @param {string | File | Blob} details.file  - The path to the file in Node.JS the File or Blob object in the Browser.
 * @param {string} details.path - The name to save the file to when it is uploaded starting with the app i.e. myapp/public/photo.jpg.
 * @param {boolean=} details.correctOrientation - **Browser Only** This will attempt to correct an images orientation based
 * on the EXIF Orientation data if any is present on the image. If no orientation is detected, or the file is not an image,
 * or the platform doesn't support the implementation then the file will be uploaded as is.
 * @example
 * //create a domain representing your developer account
 * var me = jsRiffle.Domain('xs.demo.dev');
 *
 * //create a FileStorage instance using the domain
 * var filestorage = jsRiffle.xsFileStorage(me);
 *
 * me.onJoin = function(){
 *   //upload a file to the location of path in myapp's Cloud FileStorage
 *   //Node.JS
 *   filestorage.uploadFile({file: "/path/to/file", path: 'myapp/myfile.txt'}).then(success, error);  
 *   //Browser (file is a file object)
 *   filestorage.uploadFile({file: file, path: 'myapp/myfile.txt'}).then(success, error, progress); //progess will recieve calls during upload with the percentage complete.
 * }
 *
 * app.join();
 */

FileStorage.prototype.uploadFile = function(details){
  if(!details || !details.path || !details.file){
    throw "Error: Improper arguments.";
  }
  //on node
  if(global.process && global.process.versions.node){
    return global.xsOverHTTP.uploadFile(details.file, details.path, this.conn);
  }else{
    var correct = details.correctOrientation || false;
    return this.conn.call('uploadFile', details.path, details.file.type).then(global.xsOverHTTP.uploadFile.bind({}, details.file, correct));
  }
};

/**
 * @memberof FileStorage
 * @function deleteUserFile
 * @description Delete a file from the user's collection. This function only works for users or Containers of a registered app.
 * Deleted files may take up to 15 minutes to become unavailable at the url.
 * @param {string} name - The name of the file to delete.
 * @param {string} collection - The collection or path the file is saved to.
 * @returns {boolean} - True on success.
 * @example
 * filestorage.deleteUserFile('profile.jpg', 'uploads').then(suc, err);
 */
FileStorage.prototype.deleteUserFile = function(){
  return makeCall.bind(this, 'deleteUserFile', arguments)();
};

/**
 * @memberof FileStorage
 * @function deleteFile
 * @description Delete a file located anywhere in an app's storage. This function only works for developers.
 * Deleted files may take up to 15 minutes to become unavailable at the url.
 * @param {string} path - The path to the file starting with the app. i.e. app/logo.jpg
 * @returns {boolean} - True on success.
 * @example
 * filestorage.deleteFile('app/banneduser/profile.jpg').then(suc, err);
 */
FileStorage.prototype.deleteFile = function(){
  return makeCall.bind(this, 'deleteFile', arguments)();
};

/**
 * @memberof FileStorage
 * @function deleteUserCollection
 * @description Delete a collection and it's contents  from the user's storage. This function only works for users or Containers of a registered app.
 * Deleted files may take up to 15 minutes to become unavailable at the url.
 * @param {string} collection - The collection or path to delete.
 * @returns {boolean} - True on success.
 * @example
 * filestorage.deleteUserCollection('photos/unflattering').then(suc, err);
 */
FileStorage.prototype.deleteUserCollection = function(){
  return makeCall.bind(this, 'deleteUserCollection', arguments)();
};

/**
 * @memberof FileStorage
 * @function deleteCollection
 * @description Delete a collection and it's contents from storage anywhere in an app. This function only works for developers.
 * Deleted files may take up to 15 minutes to become unavailable at the url.
 * @param {string} collection - The collection or path to delete starting with the app. i.e. app/path/to/collection
 * @returns {boolean} - True on success.
 * @example
 * filestorage.deleteCollection('app/photos/old').then(suc, err);
 */
FileStorage.prototype.deleteCollection = function(){
  return makeCall.bind(this, 'deleteCollection', arguments)();
};

/**
 * @memberof FileStorage
 * @function getUserFile
 * @description Get the url for a file in the user's storage. This function only works for users or Containers of a registered app.
 * @param {string} name - The name of the file.
 * @param {string} collecion - The collection or path where the file is located. Defaults to 'uploads'.
 * @returns {string} url - The url for the file.
 * @example
 * filestorage.getUserFile('me.jpg').then(suc, err);
 */
FileStorage.prototype.getUserFile = function(){
  return makeCall.bind(this, 'getUserFile', arguments)();
};

/**
 * @memberof FileStorage
 * @function getFile
 * @description Get the url for a file in an app's FileStorage. This function works for all subdomains of a registered app.
 * Developer's must specify the app as the first part of the path.
 * @param {string} path - The collection or path where the file is located with the file at the end. i.e. public/logo.jpg (user) or myapp/public/logo.jpg (developer)
 * @returns {string} url - The url for the file.
 * @example
 * filestorage.getFile('public/logo.jpg').then(suc, err);
 */
FileStorage.prototype.getFile = function(){
  return makeCall.bind(this, 'getFile', arguments)();
};

/**
 * @memberof FileStorage
 * @function listUserCollection
 * @description Get details about the files and subcollections for the path. This function only works for users or Containers of a registered app.
 * @param {string} path - The collection or path to list the contents of.
 * @param {boolean=} recursive - If true list all files in subcollections of this path as well. Defaults to false.
 * @returns {object} - An object describing the contents of the path.
 * @example
 * filestorage.listUserCollection('photos').then(suc, err);
 * //suc recieves an object describing the contents of the form below
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
FileStorage.prototype.listUserCollection = function(){
  return makeCall.bind(this, 'listUserCollection', arguments)();
};

/**
 * @memberof FileStorage
 * @function listCollection
 * @description Get details about the files and subcollections for the path anywhere in an app. This function only works for developers.
 * @param {string} path - The collection or path to list the contents of starting with the app. i.e. app/collection
 * @param {boolean=} recursive - If true list all files in subcollections of this path as well. Defaults to false.
 * @returns {object} - An object describing the contents of the path.
 * @example
 * filestorage.listCollection('app/photos').then(suc, err);
 * //suc recieves an object describing the contents of the form below
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
FileStorage.prototype.listCollection = function(){
  return makeCall.bind(this, 'listCollection', arguments)();
};


/**
 * @memberof $riffle
 * @function xsFileStorage
 * @description Creates a new {@link FileStorage} class.
 * @returns {FileStorage} A new FileStorage object that can be used for interacting with Exis' Cloud FileStorage system.
 * @example
 * //**Upload a File**
 * //create a domain representing your developer account
 * var fs = $riffle.xsFileStorage();
 *
 * //file is a File object
 * fs.uploadUserFile({file: file, name: 'profile.jpg'}).then(success, error, progress); //progress is repeatedly called during upload with percent complete.
 */

/**
 * @typedef FileStorage
 * @description The FileStorage class provides an API for interacting with Exis' Cloud FileStorage system
 * @example
 * **Listing files in FileStorage Service**
 * //create a FileStorage instance from the domain
 * var filestorage = $riffle.xsFileStorage();
 *
 * //get info about the contents of the directory
 * filestorage.listUserCollection('photos').then(handler, error);
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


/**
 * @memberof FileStorage
 * @function uploadUserFile
 * @description Upload a file to the user's collection. This function only works for users or Containers of a registered app.
 * @param {object} details - An object containing the details and the file to upload.
 * @param {File} details.file  - The File object.
 * @param {string} details.name - The name to save the file to when it is uploaded.
 * @param {string=} user.collection - The collection or path to store the file to. Defaults to 'uploads'.
 * @example
 *
 * //create a FileStorage instance using the domain
 * var filestorage = $riffle.xsFileStorage();
 *
 * //upload the user's profile.jpg to their 'photos' collection in Cloud FileStorage
 * //file is a File object
 * filestorage.uploadFile({file: file, name: 'profile.jpg', collection: 'photos'}).then(success, error, progress); //progess will recieve calls during upload with the percentage complete.
 *
 */

/**
 * @memberof FileStorage
 * @function uploadFile
 * @description Upload a file to a registered app's FileStorage. This function only works for developers.
 * @param {object} details - An object containing the details and the file to upload.
 * @param {File} details.file  - The File object.
 * @param {string} details.path - The name to save the file to when it is uploaded starting with the app i.e. myapp/public/photo.jpg.
 * @example
 *
 * //create a FileStorage instance using the domain
 * var filestorage = $riffle.xsFileStorage();
 *
 * //upload a file to the location of path in myapp's Cloud FileStorage
 * //file is a File object
 * filestorage.uploadFile({file: file, path: 'myapp/myfile.txt'}).then(success, error, progress); //progess will recieve calls during upload with the percentage complete.
 *
 */

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

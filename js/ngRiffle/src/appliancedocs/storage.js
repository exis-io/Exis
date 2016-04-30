/**
 * @memberof $riffle
 * @function xsStorage
 * @param {RiffleDomain} domain - A valid {@link RiffleDomain} that represents the {@link /docs/appliances/Storage Storage} appliance.
 * @description Creates a new {@link RiffleStorage} class using the given properly formed {@link RiffleDomain}.
 * @returns {RiffleStorage} A new RiffleStorage object that can be used for interacting with a {@link /docs/appliances/Storage Storage} appliance.
 * @example
 * //**Storage Example**
 * //create a storage domain
 * var storageDomain = $riffle.subdomain('Storage');
 *
 * //create a storage instance from the domain
 * var storage = $riffle.xsStorage(storageDomain);
 *
 * //create a collection 
 * var cars = storage.xsCollection('cars');
 *
 * //query the collection
 * cars.find({color: 'red'}).then(handler); //gets all red car objects from storage
 *
 */

/**
 * @typedef RiffleStorage
 * @description The RiffleStorage class links to a {@link /docs/appliances/Storage Storage} appliance and allows for creating 
 * {@link RiffleCollection collection} objects.
 * @example
 * //create a RiffleStorage instance from the domain
 * var storage = $riffle.xsStorage(storageDomain);
 *
 * //create a RiffleCollection 
 * var cars = storage.xsCollection('cars');
 */

/**
 * @memberof RiffleStorage
 * @function xsCollection
 * @param {string} name - The name of the collection in the {@link /docs/appliances/Storage Storage} appliance.
 * @description create a {@link RiffleCollection} instance to interact with the collection in the  {@link /docs/appliances/Storage Storage} appliance.
 * @example
 * //create a RiffleCollection 
 * var cars = storage.xsCollection('cars');
 */

/**
 * @memberof RiffleStorage
 * @function list_collections
 * @description Return all the collections for this {@link /docs/appliances/Storage Storage} appliance and their contents.
 * @returns {promise} - a promise that is resolve with an object with keys of the collection names and values which are arrays of the documents in the collection
 * @example
 * //list collections
 * storage.list_collection().then(handler);
 */

/**
 * @typedef RiffleCollection
 * @description The RiffleCollection class links to a {@link /docs/appliances/Storage Storage} appliance and allows for interacting with
 * {@link RiffleCollection collections}.
 * @example
 *
 * //create a RiffleCollection 
 * var cars = storage.xsCollection('cars');
 */

/**
 * @memberof RiffleCollection
 * @function create_index
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.create_index here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.create_index(key).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function delete_many
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.delete_many here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.delete_many(filter).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function delete_one
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.delete_one here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.delete_one(filter).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function distinct
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.distinct here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.distinct(key).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function drop
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.drop here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.drop().then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function drop_index
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.drop_index here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.drop_index(key).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function drop_indexes
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.drop_indexes here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.drop_indexes().then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function find
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.find here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.find().then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function find_one
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.find_one here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.find_one(filter).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function find_one_and_delete
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.find_one_and_delete here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.find_one_and_delete(filter).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function find_one_and_replace
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.find_one_and_replace here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.find_one_and_replace(filter, replacement).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function find_one_and_update
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.find_one_and_update here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.find_one_and_update(filter, update).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function insert_one
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.insert_one here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.insert_one(document).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function insert_many
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.insert_many here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.insert_many(documents).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function list_indexes
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.list_indexes here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.list_indexes().then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function rename
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.rename here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.rename(name).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function replace_one
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.replace_one here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.replace_one(filter, replacement).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function update_one
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.update_one here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.update_one(filter, update).then(handler);
 */

/**
 * @memberof RiffleCollection
 * @function update_many
 * @see {@link https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.update_many here} for documentation **kwargs not supported only positional args**.
 * @example
 * collection.update_many(filter, update).then(handler);
 */

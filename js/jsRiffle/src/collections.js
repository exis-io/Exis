module.exports = {};
var exports = module.exports;
exports.Storage = New;

function New(domain){
  return new Storage(domain);
}

function Storage(domain){
  this.storage = domain;
}

Storage.prototype.xsCollection = function(name){
  return new Collection(this.storage, name);
};

Storage.prototype.list_collections = function(){
  return this.storage.call('list_collections');
};

function Collection(storage, name){
  this.name = name;
  this.storage = storage;
}

Collection.prototype.create_index = function(keys){
  return this.storage.call('collection/create_index', this.name, keys);
};

Collection.prototype.delete_many = function(filter){
  return this.storage.call('collection/delete_many', this.name, filter);
};

Collection.prototype.delete_one = function(filter){
  return this.storage.call('collection/delete_one', this.name, filter);
};

Collection.prototype.distinct = function(key, filter){
  return this.storage.call('collection/distinct', this.name, key, filter);
};

Collection.prototype.drop = function(){
  return this.storage.call('collection/drop', this.name);
};

Collection.prototype.drop_index = function(index){
  return this.storage.call('collection/drop_index', this.name, index);
};

Collection.prototype.drop_indexes = function(){
  return this.storage.call('collection/drop_indexes', this.name);
};

Collection.prototype.find = function(filter, projection){
  return this.storage.call('collection/find', this.name, filter, projection);
};

Collection.prototype.find_one = function(filter, projection){
  return this.storage.call('collection/find_one', this.name, filter, projection);
};

Collection.prototype.find_one_and_delete = function(query, projection, sort){
  return this.storage.call('collection/find_one_and_delete', this.name, query, projection, sort);
};

Collection.prototype.find_one_and_replace = function(query, replacement, projection, sort){
  return this.storage.call('collection/find_one_and_replace', this.name, query, replacement, projection, sort);
};

Collection.prototype.find_one_and_update = function(query, update, projection, sort){
  return this.storage.call('collection/find_one_and_replace', this.name, query, update, projection, sort);
};

Collection.prototype.insert_one = function(doc){
  return this.storage.call('collection/insert_one', this.name, doc);
};

Collection.prototype.insert_many = function(documents, ordered){
  return this.storage.call('collection/insert_many', this.name, documents, ordered);
};

Collection.prototype.list_indexes = function(){
  return this.storage.call('collection/list_indexes', this.name);
};

Collection.prototype.rename = function(target){
  return this.storage.call('collection/rename', this.name, target);
};

Collection.prototype.replace_one = function(){
  var args = Array.prototype.slice.call(arguments);
  args.unshift(this.name);
  args.unshift('collection/replace_one');
  return this.storage.call.apply(this.storage, args);
};

Collection.prototype.update_one = function(){
  var args = Array.prototype.slice.call(arguments);
  args.unshift(this.name);
  args.unshift('collection/update_one');
  return this.storage.call.apply(this.storage, args);
};

Collection.prototype.update_many = function(){
  var args = Array.prototype.slice.call(arguments);
  args.unshift(this.name);
  args.unshift('collection/update_many');
  return this.storage.call.apply(this.storage, args);
};

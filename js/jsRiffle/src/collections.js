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

function makeCall(func, args){
  var args = Array.prototype.slice.call(args);
  args.unshift(this.name);
  args.unshift(func);
  return this.storage.call.apply(this.storage, args);
}

Collection.prototype.create_index = function(){
  return makeCall.bind(this, 'collection/create_index', arguments)();
};

Collection.prototype.delete_many = function(){
  return makeCall.bind(this, 'collection/delete_many', arguments)();
};

Collection.prototype.delete_one = function(){
  return makeCall.bind(this, 'collection/delete_one', arguments)();
};

Collection.prototype.distinct = function(){
  return makeCall.bind(this, 'collection/distinct', arguments)();
};

Collection.prototype.drop = function(){
  return makeCall.bind(this, 'collection/drop', arguments)();
};

Collection.prototype.drop_index = function(){
  return makeCall.bind(this, 'collection/drop_index', arguments)();
};

Collection.prototype.drop_indexes = function(){
  return makeCall.bind(this, 'collection/drop_indexes', arguments)();
};

Collection.prototype.find = function(){
  return makeCall.bind(this, 'collection/find', arguments)();
};

Collection.prototype.find_one = function(){
  return makeCall.bind(this, 'collection/find_one', arguments)();
};

Collection.prototype.find_one_and_delete = function(){
  return makeCall.bind(this, 'collection/find_one_and_delete', arguments)();
};

Collection.prototype.find_one_and_replace = function(){
  return makeCall.bind(this, 'collection/find_one_and_replace', arguments)();
};

Collection.prototype.find_one_and_update = function(){
  return makeCall.bind(this, 'collection/find_one_and_update', arguments)();
};

Collection.prototype.insert_one = function(){
  return makeCall.bind(this, 'collection/insert_one', arguments)();
};

Collection.prototype.insert_many = function(){
  return makeCall.bind(this, 'collection/insert_many', arguments)();
};

Collection.prototype.list_indexes = function(){
  return makeCall.bind(this, 'collection/list_indexes', arguments)();
};

Collection.prototype.rename = function(){
  return makeCall.bind(this, 'collection/rename', arguments)();
};

Collection.prototype.replace_one = function(){
  return makeCall.bind(this, 'collection/replace_one', arguments)();
};

Collection.prototype.update_one = function(){
  return makeCall.bind(this, 'collection/update_one', arguments)();
};

Collection.prototype.update_many = function(){
  return makeCall.bind(this, 'collection/update_many', arguments)();
};

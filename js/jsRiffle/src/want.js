module.exports = {};
var exports = module.exports;
exports.want = want;
exports.wait = wait;
exports.ModelObject = newModelObject;


/**
 *
 * want.js is a library used to wrap handlers for registered call and subscribe handlers
 * to notify the exis node of what arguments they expect to be called with so that the 
 * node can throw an error to a caller if the proper arguments are not provided. The 
 * Expectation and Model classes and Subclasses are to be used to help specify the types
 * of the arguments wanted.
 *
 */
var validTypes = [String, Boolean, Number, null, Array, Object];

function want(){
  var handler = {};
  var fp = arguments[0];
  var expect = new Expectation();
  var len = arguments.length;
  for(var i = 1; i < len; i++){
    if(validTypes.indexOf(arguments[i]) > -1 || arguments[i] instanceof ModelObject){
      expect.addArg(arguments[i], i-1);
    }else{
      try{
        var c = arguments[i].constructor;
        if(c === Array){
          expect.addArg(new ArrayWithType(arguments[i][0]), i-1);
        }else if(c === Object){
          expect.addArg(new ObjectWithKeys(arguments[i]), i-1);
        }else{
          throw "Error";
        }
      }catch(e){
        throw "Error: Inproperly formatted want statement. Argument " + (i+1) + " is invalid.";
      }
    }
  }

  function wrap(){
    // If this is associated with a reg then we must return whatever they give us
    return fp.apply(this, expect.validate(arguments));
  }
  handler.fp = wrap;
  handler.types = expect.types();

  return handler;
}

function wait(){
  var handler = {};
  var fp = arguments[0];
  var expect = new Expectation();
  var len = arguments.length;

  for(var i = 1; i < len; i++){
    if(validTypes.indexOf(arguments[i]) > -1 || arguments[i] instanceof ModelObject){
      expect.addArg(arguments[i], i-1);
    }else{
      try{
        var c = arguments[i].constructor;
        if(c === Array){
          expect.addArg(new ArrayWithType(arguments[i][0]), i-1);
        }else if(c === Object){
          expect.addArg(new ObjectWithKeys(arguments[i]), i-1);
        }else{
          throw "Error";
        }
      }catch(e){
        throw "Error: Inproperly formatted want statement. Argument " + (i + 1) + " is invalid.";
      }
    }  
  }

  function wrap(){
    // Note that we have to do arg[0] here because it returns to us differently
    // than the values passed back by want() above (this is because it is the result
    // of a yield message and is handled differently by the core).
    // for(var arg in arguments){
    //   arguments[arg] = arguments[arg][0];
    // }
    return fp.apply(this, expect.validate(arguments));
  }
  handler.fp = wrap;
  handler.types = expect.types();
  
  // This is part of a promise response from the core, so we can't pass back a handler
  // we must pass back a function pointer instead
  return handler;
}

/**
 * The Expectation class takes types of expected args and valid jsRiffle Models
 * and use the Expectation to recreate complex objects
 */

function Expectation(){
    this.args = [];
}

Expectation.prototype.types = function(){
    var argTypes = [];
    for(var i in this.args){
      argTypes.push(this.argType(this.args[i]));
    }
    return argTypes;
};

Expectation.prototype.validTypes = [String, Boolean, Number, null, Array, Object];

Expectation.prototype.typeNames = "String, Boolean, Number, null, Array, Object";

Expectation.prototype.argType =  function(type){
  if(type instanceof Model){
    return type.type();
  }
  switch(type){
    case String:
      return "str";
    case Boolean:
      return "bool";
    case Number:
      return "float";
    case null:
      return "null";
    case Array:
      return [];
    case Object:
      return {};
    default:
      throw "Error: " + type + " Is an invalid expected type.";
  }
};

Expectation.prototype.validate = function(args){
  /** I think this is all validation that should already be done in core.
  if(args.length !== this.args.length){
    throw "Error: Expected " + this.args.length + " arguments but recieved " + args.length + ".";
  }
  */
  for(var i in this.args){
    if(this.args[i] instanceof Model){
      args[i] = this.args[i].construct(args[i]);
    }
    /** I think this is all validation that should already be done in core.
    else if(this.args[i] === null || args[i] === null){
      if(args[i] === null && this.args[i] === null){
        continue;
      }else{
        if(args[i] && args[i].constructor){
          throw "Error: Expected " + this.typeName(this.args[i]) + " for argument: [" + i + "] but got " + this.typeName(args[i].constructor) + ".";
        }else{
          throw "Error: Expected " + this.typeName(this.args[i]) + " for argument: [" + i + "] but got " + args[i] + ".";
        }      
      }
    }else if(args[i] === undefined || !args[i].constructor){
      throw "Error: Invalid argument. Unknown type, no constructor found.";
    }else if(this.args[i] === args[i].constructor){
      //Type matches basic class with no validation required
      continue;
    }else{
      throw "Error: Invalid argument. Expecting " + this.typeName(this.args[i]) + " but recieved " + this.typeName(args[i].constructor) + ".";
    }
    */
  }
  return args;
};

Expectation.prototype.addArg = function(arg, index){

  if(this.validTypes.indexOf(arg) > -1 || arg instanceof Model){
    this.args[index] = arg;
  }else{
    throw "Error: Argument at index: [" + index + "] is not a valid argument type. Valid types are valid jsRiffle Models or " + this.typeNames + ".";
  }

};


/**
 * The upper most Model class signifies all valid jsRiffle Models
 */

function Model(arg){
  this.expects = new Expectation();
  this.expects.addArg(arg, 0);
}
 
Model.prototype.construct = function(){
  this.expects.validate(arguments);
};

/**
 * The ArrayWithType class validates all items existing at the specified index of the array and does any casting
 * that needs to take place.
 */

function ArrayWithType(arg){
  Model.call(this, arg);
  this.modelName = "ArrayWithType";
}

ArrayWithType.prototype = Object.create(Model.prototype);

ArrayWithType.prototype.constructor = ArrayWithType;

ArrayWithType.prototype.construct = function(array){
  for(var i in array){
    var tmp = [array[i]];
    this.expects.validate(tmp)
    array[i] = tmp[0];
  }
  return array;
};

ArrayWithType.prototype.type = function(){
  return this.expects.types();
};


/**
 * The ObjectWithKeys class validates the all keys exist within the object and that any casting
 * that needs to take place does.
 */

function ObjectWithKeys(arg){
  try{
    if(arg.constructor !== Object){
      throw "Error: The expected arg must be an Object.";
    }
    Model.call(this, Object);
  }catch(e){
    throw "Error: Expecting a valid object template to be passed in. i.e. {key: String}";
  }
  this.expects = new Expectation();
  this.keyToArgMap = [];
  for(var key in arg){
    this.expects.addArg(arg[key], this.keyToArgMap.length);
    this.keyToArgMap.push(key);
  }
  this.modelName = "ObjectWithKeys";
}

ObjectWithKeys.prototype = Object.create(Model.prototype);

ObjectWithKeys.prototype.constructor = ObjectWithKeys;

ObjectWithKeys.prototype.type = function(){
  var type = {};
  for(var i in this.keyToArgMap){
    type[this.keyToArgMap[i]] = this.expects.argType(this.expects.args[i]);
  }
  return type;
};

ObjectWithKeys.prototype.construct = function(obj){
  /** Uneccessary should be done in core
  for(var i in this.keyToArgMap){
    if(obj[this.keyToArgMap[i]] === undefined){
      throw "Error: Argument missing expected key: " + this.keyToArgMap[i] + ".";
    }
  }
  **/

  var vals = [];
  for(var key in obj){
    var index = this.keyToArgMap.indexOf(key);
    if(index === -1){
      throw "Error: Argument contains unexpected key: " + key + ".";
    }else{
      vals[index] = obj[key];
    }
  }
  this.expects.validate(vals);
  for(var j in vals){
    obj[this.keyToArgMap[j]] = vals[j];
  }
  return obj;
};


/**
 * The ModelObject casts an Object into a new object constructed with the specified constructor
 * by iterating through the keys and dropping the key/value pair into the new object overwriting any keys with the
 * same name already created via the constructor.
 */

function ModelObject(constructor){
    this.myConstructor = constructor;
    var self = this;

    constructor.prototype.save = function(){
      self.assertBound();
      if(!this._id){
        function helper(result){
          this._id = result.inserted_id;
          return result;
        }
        return self.__storage.call("collection/insert_one", self.__collection, this).then(wait(helper, Object));
      }else{
        return self.__storage.call("collection/replace_one", self.__collection, {'_id': this._id}, this, true);
      }
    };

    constructor.prototype.delete = function(){
      self.assertBound();
      if(!this._id){
        throw Error("No ID associated with this object model. Failed to delete object from storage.");
      }else{
        return self.__storage.call("collection/delete_one", self.__collection, {'_id': this._id});
      }
    };

    this.modelName = "ModelObject";
    var expectedTypes = {};
    var cls = new constructor();
    for(var key in cls){
      if(validTypes.indexOf(cls[key]) > -1 || cls[key] instanceof Model){
        expectedTypes[key] = cls[key];
      }
    }
    ObjectWithKeys.call(this, expectedTypes);
}

ModelObject.prototype = Object.create(ObjectWithKeys.prototype);

ModelObject.prototype.constructor = ModelObject;

ModelObject.prototype.construct = function(){
  this.expects.validate(arguments);
  var dict = arguments[0];
  var newObj = new this.myConstructor();
  for(var i in dict){
    newObj[i] = dict[i];
  }
  return newObj;
};

ModelObject.prototype.bind = function(owner, appliance, collection){
  if(typeof(collection) !== 'string' && collection !== undefined){
    throw Error("collection must be a string");
  }
  if(!owner){
    throw Error("A domain must be passed in to the the model to.");
  }
  if(this.__storage !== undefined){
    throw Error("Model already bound."); 
  }
  var inst = new this.myConstructor();
  if(!collection){
    collection = inst.constructor.name;
  }
  if(collection.length === 0){
    throw Error("No class name for this model's constructor could be found. Call bind with the model name as the second argument to set the name manually.");
  }
  this.__collection = collection;
  if(appliance){
    this.__storage = owner.linkDomain(appliance);
  }else{
    this.__storage = owner;
  }
  this.__bound = true;
};

ModelObject.prototype.assertBound = function(){
  if(!this.__bound){
    throw Error("Model not bound.");
  }
};

ModelObject.prototype.find = function(query){
  if(query === undefined){
    query = {};
  }
  this.assertBound();
  var self = this;
  function passer(args){
    return args;
  }
  return this.__storage.call("collection/find", this.__collection, query).then(wait(passer, [this]));
};

ModelObject.prototype.find_one = function(query){
  if(query === undefined){
    query = {};
  }
  this.assertBound();
  function passer(args){
    return args;
  }
  return this.__storage.call("collection/find_one", this.__collection, query).then(wait(passer, this));
};


function newModelObject(constructor){
  return new ModelObject(constructor);
}

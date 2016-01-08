/**
 *
 * want.js is a library used to wrap handlers for registered call and subscribe handlers
 * to notify the exis node of what arguments they expect to be called with so that the 
 * node can throw an error to a caller if the proper arguments are not provided. The 
 * Expectation and Model classes and Subclasses are to be used to help specify the types
 * of the arguments wanted.
 *
 */

function want(){
  var handler = {};
  var fp = arguments[0];
  var expect = new Expectation();
  var len = arguments.length;
  for(var i = 1; i < len; i++){
    expect.addArg(arguments[i], i-1);
  }

  function wrap(){
    fp.apply(this, expect.validate(arguments));
  }
  handler.fp = wrap;
  handler.types = expect.types();

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
 * The ObjectModel class signifies all models that are constructed from Objects
 */

function ObjectModel(obj){
    if(obj !== Object && !(obj instanceof ObjectModel)){
      throw "Error: Must be the expected arg must be either a Object or a valid jsRiffle ObjectModel type.";
    }
    Model.call(this, obj);
}

ObjectModel.prototype = Object.create(Model.prototype);

ObjectModel.prototype.constructor = ObjectModel;

/**
 * The ObjectWithKeys class validates the all keys exist within the object and that any casting
 * that needs to take place does.
 */

function ObjectWithKeys(arg){
  try{
    ObjectModel.call(this, arg.constructor);
  }catch(e){
    throw "Error: ObjectWithKeys requires a valid object template to be passed in.";
  }
  this.expects = new Expectation();
  this.keyToArgMap = [];
  for(var key in arg){
    this.expects.addArg(arg[key], this.keyToArgMap.length);
    this.keyToArgMap.push(key);
  }
  this.modelName = "ObjectWithKeys";
}

ObjectWithKeys.prototype = Object.create(ObjectModel.prototype);

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
 * The ObjectToClass casts an Object or ObjectModel into a new object constructed with the specified constructor
 * by iterating through the keys and dropping the key/value pair into the new object overwriting any keys with the
 * same name already created via the constructor.
 */

function ObjectToClass(constructor, arg){
    this.myConstructor = constructor;
    this.modelName = "ObjectToClass";
    ObjectModel.call(this, arg);
}

ObjectToClass.prototype = Object.create(ObjectModel.prototype);

ObjectToClass.prototype.constructor = ObjectToClass;

ObjectToClass.prototype.construct = function(){
  this.expects.validate(arguments);
  var dict = arguments[0];
  var newObj = new this.myConstructor();
  for(var i in dict){
    newObj[i] = dict[i];
  }
  return newObj;
};

ObjectToClass.prototype.type = function(){
  return this.expects.types()[0];
};

'''
Type reflection and conversion.
'''

import inspect
import json

from riffle import utils, model

def want(*types):
    def real_decorator(function):
        def wrapper(*args, **kwargs):
            # return the types this call expects as a list if asked
            if '_riffle_reflect' in kwargs:
                return list(types)

            # Test if function looks like a method and set aside the first
            # argument.  At first glance, inspect.ismethod should tell us this,
            # but it doesn't, so for now we just look for a "self" argument.
            pre_args = tuple()
            argspec = inspect.getargspec(function).args
            if argspec and argspec[0] == "self":
                pre_args = args[0:1]
                args = args[1:]

            final_args = pre_args + unmarshall(args, types)

            return function(*final_args)
        return wrapper
    return real_decorator

def reflect(handler):
    '''
    Reflectes the expected types of the receiver and returns them as a json serialized list.

    If no @want is specified, None is returned. This allows any arguments.
    '''
    try:
        types = handler(_riffle_reflect=True)
    except TypeError, e:
        # If the method does not accept a _riffle_reflect, its not a wrapped function and 
        # thus accepts any argument
        # TODO: HOWEVER-- a **kwargs function will fail here. Have to catch **kwargs functions
        # and immediately err on them! Receives can only accept *args and may embed as elements
        return json.dumps([None])

    return prepareSchema(types)

def prepareSchema(types):
    '''
    Prepares a list of types for consumption by the core. Returns json.
    '''
    if types is None:
        return json.dumps([None])
    else:
        typeList = []

        for t in types:

            # If primitive type, continue
            if t in [int, float, bool, str, list, dict]:
                typeList.append(t.__name__)

            # Format passed in should be [bool]. Internal types should be homogenous
            # Output should be [bool]
            elif type(t) is list:
                if len(t) > 1:
                    raise utils.SyntaxError("Lists can only have one internal type.")

                if t[0] in [int, float, bool, str, list, dict]:
                    typeList.append([t[0].__name__])
                else: 
                    raise utils.SyntaxError("Unknown type ", t[0])

            # Same as above-- homogenous key:value pairs, OR just the dict itself
            elif t is dict:
                typelist.append({k: v.reflect() if isinstance(v, Model) else v for k, v in t})

            elif issubclass(t, model.Model):
                typeList.append(t.reflect())

            else:
                print 'Type ' + str(t) + ' is not natively serializible!'

    return json.dumps(typeList)

def marshall(args):
    ''' Ask models to serialize themselves, if present. Returns JSON. '''
    return json.dumps([x._serialize() if isinstance(x, model.Model) else x for x in args])

def unmarshall(args, types):
    '''
    Prepares arguments from the core for user level code. 

    Objects and exceptions are recreated from dictionaries if appropriate. 
    '''

    # If types is None, allow all arguments
    if not types:
        return args

    # return tuple([x._deserialize() if isinstance(x, Model) else y for x, y in zip(types, args)])

    l = list()
    for x, y in zip(args, types):
        if issubclass(y, model.Model):
            l.append(y._deserialize(x))
        else:
            l.append(x)
    return tuple(l)

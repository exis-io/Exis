
import inspect

from riffle.model import reconstruct

def want(*types):
    def real_decorator(function):
        def wrapper(*args, **kwargs):
            # return the types this call expects as a list if asked
            if '_riffle_reflect' in kwargs:
                # return [x.__name__ for x in list(types)]
                return list(types)

            # Test if function looks like a method and set aside the first
            # argument.  At first glance, inspect.ismethod should tell us this,
            # but it doesn't, so for now we just look for a "self" argument.
            pre_args = tuple()
            argspec = inspect.getargspec(function).args
            if argspec and argspec[0] == "self":
                pre_args = args[0:1]
                args = args[1:]

            final_args = pre_args + reconstruct(args, types)

            return function(*final_args)
        return wrapper
    return real_decorator


def cuminReflect(handler):
    '''
    Reads the types the receiver expects to receive and returns them as a list. 

    If no @want is specified, None is returned. This allows any arguments.

    No arguments are denoted by an empty list. The decorator is @want() 
    '''
    try:
        types = handler(_riffle_reflect=True)
    except TypeError, e:
        # If the method does not accept a _riffle_reflect, its not a wrapped function and 
        # thus accepts any argument
        # TODO: HOWEVER-- a **kwargs function will fail here. Have to catch **kwargs functions
        # and immediately err on them! Receives can only accept *args and may embed as elements
        return None

    typeList = []

    if types is None:
        return typeList
    else:
        for t in types:

            # If primitive type, continue
            if t in [int, float, bool, str, list, dict]:
                typeList.append(t.__name__)

            # Format passed in should be [bool]. Internal types should be homogenous
            # Output should be [bool]
            elif type(t) is list:
                print 'List serialization not implemented'

            # Same as above-- homogenous key:value pairs, OR just the dict itself
            elif t is dict:
                print 'Dictionary serialization not implemented'

            elif issubclass(t, Model):
                typeList.append(t.reflect())

            else:
                print 'Type ' + str(t) + ' is not natively serializible!'

    return typeList

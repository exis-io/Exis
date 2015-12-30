
import sys
import os


class Model(object):

    @classmethod
    def reflect(klass):
        '''
        Build a schema from the types listed as class variables and return it.

        Can also store it as a class variable. 

        The format of the returned data is: 
            {'email': 'str', 'name': 'str'}
        '''

        attrs = {}

        for s in dir(klass):

            # Skip internal stuff
            if(s.startswith("_")):
                continue

            a = getattr(klass, s)

            # If they defined just a type, call it so it returns the default value
            if(isinstance(a, type)):
                a = a.__call__()

            # Skip functions
            elif(hasattr(a, "__call__")):
                continue

            attrs[s] = type(a).__name__

        # klass.__schema = attrs
        return attrs

    def __init__(self, **kwargs):
        attrs = {}
        values = {}

        # Scan everything in the class
        for s in dir(self):

            # Skip internal stuff
            if(s.startswith("_")):
                continue

            a = getattr(self, s)

            # If they defined just a type, call it so it returns the default value
            if(isinstance(a, type)):
                a = a.__call__()

            # Skip functions
            elif(hasattr(a, "__call__")):
                continue

            attrs[s] = type(a).__name__
            values[s] = a

            # Update with values that were set as arguments.
            values.update(kwargs)

            # Now set their dict to include these values (translates the Class
            # variables back into instance vars)
            self.__attrs = attrs
            self.__values = values

            # Every object that is in the storage will have an _id field.
            self.__id = None

    def __getattr__(self, name):
        if name.startswith("_"):
            return self.__dict__[name]
        else:
            return self.__values[name]

    def __setattr__(self, name, value):
        if name.startswith("_"):
            super(Model, self).__setattr__(name, value)
        else:
            self.__values[name] = value

    def __repr__(self):
        return str(self.__class__) + repr(self.__values)

    @classmethod
    def _deserialize(cls, json): 
        c = cls(**json)
        return c

    def _serialize(self): 
        return self.__values 

def want(*types):
    def real_decorator(function):
        def wrapper(*args, **kwargs):
            # return the types this call expects as a list if asked
            if '_riffle_reflect' in kwargs: 
                # return [x.__name__ for x in list(types)]
                return list(types)
            
            l = list()
            for x, y in zip(args, types):
                if issubclass(y, Model):
                    l.append(y._deserialize(x))
                else:
                    l.append(x)
            
            return function(*l)
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
        # If the method does not accept a _riffle_reflect, its not a wrapped function
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


class RiffleError(Exception):
    pass

class Unimplemented(RiffleError):
    pass
    
##############################
# Inline testing, please ignore
##############################

class User(Model):
    name = "John Doe"
    email = ''

    def __init__(self, email):
        super(User, self).__init__()


# Testing
@want(int, str, User)
def fn(a, b):
    print 'Function Called!'

def notSpeciffied(a, b):
    pass



def testDecorators():
    print cuminReflect(fn)
    print cuminReflect(notSpeciffied)


def testModels():
    print User.reflect()

    lance = User(25)
    lance.name = "Lance"
    lance.email = "lance@exis.io"

    lance.age = 15

    print lance._serialize()

if __name__ == "__main__":
    # testModels()
    testDecorators()

'''
Base implementation of Model class
'''

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

        # Need to set their __dict__ so they are visible as inst.varName
        self.__dict__.update(kwargs)
        
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
        return str(self.__class__.__name__) + repr(self.__values)

    @classmethod
    def _deserialize(klass, json):
        # TODO: apply deserialze recursively to nested models and collections of models
        return klass(**json)

    def _serialize(self):
        # TODO: apply serialize recursively to nested models
        # TODO: check values, make sure they're serializable, else throw an exception
        return self.__values

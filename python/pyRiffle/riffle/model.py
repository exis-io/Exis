'''
Base implementation of Model class
'''

import sys
import os

class ModelObject(object):
    __collection = None
    __storage = None

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
        self.__attrs = dict()
        self.__values = dict()

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

            self.__attrs[s] = type(a)
            self.__values[s] = a

        # Update with values that were set as arguments.
        self.__values.update(kwargs)

        # Every object that is in the storage will have an _id field.
        self.__id = None

    def __getattribute__(self, name):
        if name.startswith("_") or name not in self.__values:
            return super(ModelObject, self).__getattribute__(name)
        else:
            return self.__values[name]

    def __setattr__(self, name, value):
        if name.startswith("_"):
            super(ModelObject, self).__setattr__(name, value)
        else:
            if name not in self.__values:
                raise AttributeError("Model class {} does not have an attribute {}"
                        .format(self.__class__.__name__, name))
            elif not isinstance(value, self.__attrs[name]):
                raise TypeError("For attribute {} expected type {}, received {}"
                        .format(name, self.__attrs[name].__name__,
                            type(value).__name__))
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

    #
    # Methods for model object persistence.
    #

    @classmethod
    def attachStorage(klass, storage, collection=None):
        """
        Attach this model to a storage domain for persistence.

        If collection is not specified, the default behavior is to use the
        class name as the collection.

        storage: instance of a riffle.Domain
        collection: name of collection to use
        """
        if klass.__storage is not None:
            raise Exception("Model {} already attached to storage".
                    format(klass.__name__))
        if collection is None:
            collection = klass.__name__
        klass.__collection = collection
        klass.__storage = storage

    def save(self):
        """
        Write the object back to storage.
        """
        if self.__storage is None:
            raise Exception("Model {model} is not attached to storage; "
                    "you should call {model}.attachStorage first"
                    .format(model=self.__class__.__name__))
        elif self.__id is None:
            d = self.__storage.call("collection/insert_one",
                    self.__collection,
                    self._serialize())
            # TODO: d.wait({'$atleast': {'inserted_id': str}})
            result = d.wait(dict)
            self.__id = result.get('inserted_id', None)
            print("id: {}".format(self.__id))
        else:
            self.__storage.call("collection/replace_one",
                    self.__collection,
                    {'_id': self.__id},
                    self._serialize(),
                    True).wait()


# Model is deprecated.
#
# We should prefer ModelObject or some variation as a class name so that "is a"
# relationships make sense for instances of the class.
#
# Example: suppose Person is a subclass of ModelObject, and dale is an instance
# Person.  Logically, dale is a Person, dale is a ModelObject (an object that
# conforms to the Person model), but dale is not a Model.
Model = ModelObject

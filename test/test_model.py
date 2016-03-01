from nose.tools import assert_raises

from riffle.model import ModelObject

def test_subclass():
    class Person(ModelObject):
        name = str
        age = int
        cool = False

    dale = Person(name="Dale")
    dale.cool = True

    # Value set through constructor
    assert dale.name == "Dale"

    # Value not set (default for int type)
    assert dale.age == 0

    # Value set through setattr
    assert dale.cool

    with assert_raises(AttributeError) as error:
        dale.missing = 5

    with assert_raises(TypeError) as error:
        dale.age = "bad"

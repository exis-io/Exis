from riffle.model import ModelObject

def test_recursive_prepareSchema():
    from riffle.cumin import _prepareSchema

    assert _prepareSchema(None) is None

    assert _prepareSchema(int) == "int"
    assert _prepareSchema(float) == "float"
    assert _prepareSchema(bool) == "bool"
    assert _prepareSchema(str) == "str"
    assert _prepareSchema(list) == "list"
    assert _prepareSchema(dict) == "dict"

    assert _prepareSchema([str]) == ['str']

    assert _prepareSchema({'test': int}) == {'test': 'int'}

    class Person(ModelObject):
        name = str
    assert _prepareSchema(Person) == {'name': 'str'}

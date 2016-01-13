def test_unmarshall():
    from riffle.cumin import unmarshall

    # types set to None just returns the arguments
    assert unmarshall([42], None) == (42, )

    assert unmarshall([1, 2], [int, int]) == (1, 2)
    assert unmarshall([1, "a"], [int, str]) == (1, "a")


def test_unmarshall_object():
    from riffle.cumin import unmarshall
    from riffle.model import ModelObject

    class Person(ModelObject):
        name = str

    dale = Person(name="Dale")
    dale_s = dale._serialize()

    lance = Person(name="Lance")
    lance_s = lance._serialize()

    # Person objects as arguments
    assert unmarshall([dale_s], [Person]) == (dale, )
    assert unmarshall([dale_s, lance_s], [Person, Person]) == (dale, lance)

    # List of Person objects as an argument
    assert unmarshall([[]], [[Person]]) == ([], )
    assert unmarshall([[dale_s]], [[Person]]) == ([dale], )
    assert unmarshall([[dale_s, lance_s]], [[Person]]) == ([dale, lance], )

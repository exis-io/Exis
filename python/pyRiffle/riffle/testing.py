
from greenlet import greenlet


def register(n):
    print "Registering :", n
    return Deferred()

def target():
    register(0)

    for i in [1, 2, 3]:
        data = yield register(i)
        print 'Got data: ', data

    yield "Done"

def testGenerators():
    fn = target

    if inspect.isgeneratorfunction(fn):
        print 'isGenerator'
        t = fn()
        a = t.send(None)

        while a is not None:
            try:
                print 'Produced: ', a

                # Sleep this greenlet until the call comes back...

                a = t.send('asdf')

            except StopIteration, e:
                print 'Iteration finished'
                break

    # If the call returns a deferred, then:
    # makeCall
    # Set Callback
    # Switch

    # When the call returns:
    # Evaluate Results
    # Send results
    # Continie


def want(*types):
    def real_decorator(function):
        def wrapper(*args):
            print "Args", args
            print 'Types', types

            # Works for enforcement, but we actually dont care about enforcement... until it comes to objects
            for t, a, in zip(types, args):
                print t, a

            function(*args)

        return wrapper
    return real_decorator

@want(int, str)
def fn(a, b):
    print 'Function Called!'

def testDecorators():
    print fn(1, '2')
    print fn


class Deferred(object):
    def __init__(self):
        self.greenlet = greenlet()

    def wait(self):
        # We should receive a set of args here and return
        pass

def recv():
    ''' Spin on the receive loop, get results '''

def test1():
    print 12
    gr2.switch()
    print 34

def test2():
    print 56
    gr1.switch()
    print 78

gr1 = greenlet(test1)
gr2 = greenlet(test2)

def testGreenlets():
    
    gr1.switch()


if __name__ == '__main__':
    testGreenlets()
    # testGenerators()
    # testDecorators()


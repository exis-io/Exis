
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


def recv():
    ''' Spin on the receive loop, get results '''

    joined = greenlet(onJoin)
    waiting = joined.switch()

    print 'Joined returned with greenlent', waiting

    a = [1, 2, 3, 4, 5]

    while True:
        print 'Starting spin loop'
        args = a.pop(0)

        waiting = waiting.switch(args)

        if waiting is None:
            print 'No greenlets left. Continue spinning now?'

            return


spinner = greenlet(recv)


class Deferred(object):

    # def __init__(self):
    #     self.greenlet = greenlet()

    def wait(self):
        # We should receive a set of args here and return

        return spinner.switch(greenlet.getcurrent())


def onJoin():
    ''' Starts in a greenlet '''
    print 'onJoin'

    a = test1().wait()
    print 'A wait done', a

    b = test2().wait()
    print 'B wait done', b

    # print 'Done'


def test1():
    print 'Test 1 started'
    return Deferred()


def test2():
    print 'Test 2 started'
    return Deferred()


gr1 = greenlet(test1)
gr2 = greenlet(test2)


def testGreenlets():
    spinner.switch()


if __name__ == '__main__':
    testGreenlets()
    # testGenerators()
    # testDecorators()

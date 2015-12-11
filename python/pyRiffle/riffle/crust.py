
from greenlet import greenlet
import ctypes
import random
import os
import json

# When runnin as a package
# _DIRNAME = os.path.dirname(__file__)
# go = ctypes.cdll.LoadLibrary(os.path.join(_DIRNAME, 'libriffmantle.so'))

# When running locally-- no gopy
# mantle = ctypes.cdll.LoadLibrary('./libriffmantle.so')

# When running with gopy
import riffle

class Deferred(object):

    def __init__(self):
        self._callback, self._errback = None, None
        self._callbackId, self._errbackId = -1, -1

def cbid():
    return int(random.getrandbits(64))

class App(object):

    def __init__(self):
        self._app = riffle.App()
        self._app.Init()

        # Dictionary of uints to callbacks (?)
        self.callbacks = {}

    def recv(self):
        while True:
            callbackId, args = json.loads(self._app.Receive())

            if callbackId in self.callbacks:
                self.callbacks[callbackId](*args if args is not None else [])
            else:
                print "No handler available for ", callbackId


# Internalize this reference into the domain object. For now, its ok global
app = App()


class Domain(object):

    def __init__(self, name):
        self.mantleDomain = app._app.NewDomain(name)
        self.name = name

    def join(self):
        cb, eb = cbid(), cbid()

        app.callbacks[cb] = self.onJoin

        self.mantleDomain.Join(cb, eb)
        app.recv()

    def onJoin(self):
        print "Domain %s joined!" % self.name

    def subscribe(self, endpoint, handler):
        fn = cbid()
        self.mantleDomain.Subscribe(fn, endpoint)
        app.callbacks[fn] = handler

    def register(self, endpoint, handler):
        fn = cbid()
        self.mantleDomain.Register(fn, endpoint)
        app.callbacks[fn] = handler

def main():
    d = Domain("xs.damouse")
    d.join()

if __name__ == '__main__':
    main()


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

riffle.SetLoggingLevel(3)

class Deferred(object):

    def __init__(self):
        self._callback, self._errback = None, None
        self._callbackId, self._errbackId = -1, -1


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
                print "Calling with ", args
                self.callbacks[callbackId](*args)
            else:
                print "No handler available for ", callbackId


# Internalize this reference into the domain object. For now, its ok global
app = App()


class Domain(object):

    def __init__(self, name):
        self._domain = app._app.NewDomain(name)
        self.name = name

    def join(self):
        cb, eb = int(random.getrandbits(64)), int(random.getrandbits(64))

        app.callbacks[cb] = self.onJoin

        self._domain.Join(cb, eb)
        app.recv()

    def onJoin(self):
        print "Domain %s joined!" % self.name

    def subscribe(self, endpoint, handler):
        cb = int(random.getrandbits(64))
        self._domain.Subscribe(endpoint)
        app.callbacks[cb] = handler

def main():
    d = Domain("xs.damouse")
    d.join()

if __name__ == '__main__':
    main()


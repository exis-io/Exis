
import random
import os
import json

from greenlet import greenlet

import riffle

# Create a new random callback id
def cbid():
    return random.getrandbits(53)

class Deferred(object):
    def __init__(self):
        cb, eb = None, None

class App(object):

    def __init__(self):
        self.registrations, self.subscriptions, self.results, self.control = {}, {}, {}, {}

    def recv(self, domain):
        while True:
            i, args = json.loads(domain.Receive())
            args = args if args is not None else []

            # Wrap it all in a try-catch, return publish and call errors
            # Don't return yield errors-- its not clear who should deal with those 

            # Turned out to work as a leave case, though this isn't  clean
            if i == 0:
                break

            # Possible remove meta on completion
            if i in self.control:
                self.control[i](*args)

            elif i in self.subscriptions:
                self.subscriptions[i](*args)

            # Remove results on completion
            elif i in self.results:
                self.results[i](*args)

            elif i in self.registrations:
                returnId = args.pop(0)

                ret = self.registrations[i](*args)
                ret = [] if ret is None else ret

                if not isinstance(ret, (list, tuple)):
                    ret = [ret]

                domain.Yield(returnId, json.dumps(ret))

            else: 
                riffle.Error("No handler available for " + str(i))

class Domain(object):

    def __init__(self, name, superdomain=None):
        self.name = name

        if superdomain is None:
            self.mantleDomain = riffle.NewDomain(name)
            self.app = App()
        else:
            self.mantleDomain = superdomain.mantleDomain.Subdomain(name)
            self.app = superdomain.app

    def join(self):
        cb, eb = cbid(), cbid()
        self.app.control[cb] = self.onJoin
        self.mantleDomain.Join(cb, eb)

        # Make this explicit by putting it in its own method?
        self.app.recv(self.mantleDomain)

    def onJoin(self):
        riffle.Info("Default onJoin")

    def onLeave(self):
        riffle.Info("Default onLeave")

    def subscribe(self, endpoint, handler):
        fn = cbid()
        self.mantleDomain.Subscribe(fn, endpoint)
        self.app.subscriptions[fn] = handler

    def register(self, endpoint, handler):
        fn = cbid()
        self.mantleDomain.Register(fn, endpoint)
        self.app.registrations[fn] = handler

    def publish(self, endpoint, *args):
        self.mantleDomain.Publish(cbid(), endpoint, json.dumps(args))

    def call(self, endpoint, handler, *args):
        fn = cbid()
        self.mantleDomain.Call(fn, endpoint, json.dumps(args))

        if handler is not None:
            self.app.results[fn] = handler

    def leave(self):
        self.mantleDomain.Leave()

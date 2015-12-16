
import random
import os
import json

from greenlet import greenlet

import riffle


def newID(n):
    ''' Returns n random unsigned integers to act as Callback Ids '''
    return tuple([random.getrandbits(53) for x in range(n)])


class App(object):

    def __init__(self):
        self.registrations, self.subscriptions, self.results, self.control = {}, {}, {}, {}

    def recv(self, domain):
        while True:
            i, args = json.loads(domain.Receive())
            args = args if args is not None else []

            # Wrap it all in a try-catch, return publish and call errors
            # Don't return yield errors-- its not clear who should deal with those

            print "Invoking with id " + str(i) + " args: " + str(args)

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
        cb, eb = newID(2)

        self.app.control[cb] = self.onJoin
        self.mantleDomain.Join(cb, eb)

        # Make this explicit by putting it in its own method?
        self.app.recv(self.mantleDomain)

    def onJoin(self):
        riffle.Info("Default onJoin")

    def onLeave(self):
        riffle.Info("Default onLeave")

    def subscribe(self, endpoint, handler):
        cb, eb, fn = newID(3)
        self.mantleDomain.Subscribe(endpoint, cb, eb, fn, json.dumps([]))
        self.app.subscriptions[fn] = handler

    def register(self, endpoint, handler):
        cb, eb, fn = newID(3)
        self.mantleDomain.Register(endpoint, cb, eb, fn, json.dumps([]))
        self.app.registrations[fn] = handler

    def publish(self, endpoint, *args):
        cb, eb = newID(2)
        self.mantleDomain.Publish(endpoint, cb, eb, json.dumps(args))

    def call(self, endpoint, handler, *args):
        cb, eb = newID(2)
        self.mantleDomain.Call(endpoint, cb, eb, json.dumps(args), json.dumps([]))

        if handler is not None:
            self.app.results[cb] = handler

    def leave(self):
        self.mantleDomain.Leave()

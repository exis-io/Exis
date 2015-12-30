
import random
import os
import json

from greenlet import greenlet

import pymantle
from riffle.model import Model, cuminReflect

'''
I made a mistake. Deferreds should only cover success/failure callbacks, while the handlers
are only for register/subscribe

Fixing the osx python version: 
    https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Common-Issues.md#python-segmentation-fault-11-on-import-some_python_module
'''


def newID(n=1):
    ''' Returns n random unsigned integers to act as Callback Ids '''
    return random.getrandbits(53) if n == 1 else tuple([random.getrandbits(53) for x in range(n)])


class Deferred(object):

    '''
    Non-general purpose deferred object associated with and resolved by ID-indexed invocations from 
    coreRiffle. 

    Callbacks can only be fired once. 
    '''

    def __init__(self):
        self.cb, self.eb = newID(2)
        self.green = None

    def wait(self, *types):
        ''' Wait until the results of this invocation are resolved '''
        # TODO: pass typelist down to call for later checking

        # Pass our ids so the parent knows when to reinvoke
        self.green = greenlet.getcurrent()
        results = self.green.parent.switch(self)
        return results


class App(object):

    def __init__(self):
        self.deferreds, self.registrations, self.subscriptions = {}, {}, {}
        self.control = {}

        # The greenlet that runs the handle loop
        self.green = None

    def handle(self, domain):
        ''' Open connection with the core and begin handling callbacks '''

        while True:
            i, args = json.loads(domain.Receive())
            args = [] if args is None else args

            # Turned out to work as a leave case, though this isn't clean
            if i == 0:
                break

            if i in self.deferreds:
                d = self.deferreds[i]

                # Resolve the deferred
                del self.deferreds[d.cb]
                del self.deferreds[d.eb]

                # Handle success seperate from failures-- Might be able to just pass in an appropriate exception
                if d.green is not None:
                    print 'Reentering deffered with ', args
                    d = d.green.switch(*args)

                    # If user code called .wait() agaain we get another deferred
                    if d is not None:
                        self.deferreds[d.cb], self.deferreds[d.eb] = d, d

            # Orphaned-- onJoin and other control messages should be handled with their own deferreds
            if i in self.control:
                task = greenlet(self.control[i])
                d = task.switch(*args)

                # If user code called .wait(), this deferred is emitted, waiting on the results of some operation
                if d is not None:
                    self.deferreds[d.cb], self.deferreds[d.eb] = d, d

            elif i in self.subscriptions:
                self.subscriptions[i](*args)

            elif i in self.registrations:
                returnId = args.pop(0)

                ret = self.registrations[i](*args)
                ret = [] if ret is None else ret

                if not isinstance(ret, (list, tuple)):
                    ret = [ret]

                domain.Yield(returnId, json.dumps(ret))

            else:
                pass
                # riffle.Error("No handler available for " + str(i))

    def maybeDeferred(self):
        ''' Call some function with some args. If that function produces a deferred, add it to our list'''
        pass


class Domain(object):

    def __init__(self, name, superdomain=None):
        self.name = name

        if superdomain is None:
            self.mantleDomain = pymantle.NewDomain(name)
            self.app = App()
        else:
            self.mantleDomain = superdomain.mantleDomain.Subdomain(name)
            self.app = superdomain.app

    def join(self):
        cb, eb = newID(2)
        self.app.control[cb] = self.onJoin
        self.mantleDomain.Join(cb, eb)

        # Start the handler loop, send the join, then handle from there

        spin = greenlet(self.app.handle)
        self.app.green = spin
        spin.switch(self.mantleDomain)

    def onJoin(self):
        pymantle.Info("Default onJoin")

    def onLeave(self):
        pymantle.Info("Default onLeave")

    def subscribe(self, endpoint, handler):
        d = Deferred()
        hn = newID()

        # types = cuminReflect(handler)
        # print 'Subscribing with types:', types

        self.app.deferreds[d.cb], self.app.deferreds[d.eb] = d, d
        self.app.subscriptions[hn] = handler
        self.mantleDomain.Subscribe(endpoint, d.cb, d.eb, hn, json.dumps([]))
        return d

    def register(self, endpoint, handler):
        d = Deferred()
        hn = newID()

        # types = cuminReflect(handler)
        # print 'Registering with types:', types

        self.app.deferreds[d.cb], self.app.deferreds[d.eb] = d, d
        self.app.registrations[hn] = handler
        self.mantleDomain.Register(endpoint, d.cb, d.eb, hn, json.dumps(cuminReflect(handler)))
        return d

    def publish(self, endpoint, *args):
        d = Deferred()
        l = list()
        for arg in args:
            l.append(arg._serialize() if isinstance(arg, Model) else arg)
        self.app.deferreds[d.cb], self.app.deferreds[d.eb] = d, d
        self.mantleDomain.Publish(endpoint, d.cb, d.eb, json.dumps(l))
        return d

    def call(self, endpoint, *args):
        d = Deferred()
        self.app.deferreds[d.cb], self.app.deferreds[d.eb] = d, d
        self.mantleDomain.Call(endpoint, d.cb, d.eb, json.dumps(args), json.dumps(cuminReflect(handler)))
        return d

    def leave(self):
        # Deferreds here, please
        self.mantleDomain.Leave()

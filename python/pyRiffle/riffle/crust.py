
import random
import os
import json

from greenlet import greenlet

import riffle

'''
I made a mistake. Deferreds should only cover success/failure callbacks, while the handlers
are only for register/subscribe
'''


def newID(n):
    ''' Returns n random unsigned integers to act as Callback Ids '''
    return tuple([random.getrandbits(53) for x in range(n)])


class Deferred(object):

    '''
    Non-general purpose deferred object associated with and resolved by ID-indexed invocations from 
    coreRiffle. 

    Callbacks can only be fired once. 
    '''

    def __init__(self, isRegistration=False):
        self.callback, self.errback = None, None
        self.cb, self.eb = newID(3)

        self.isRegistration = isRegistration

    def _invoke(self, deferredList, invocation, args):
        ''' This represents a request to invoke one of the handlers on this deferred. '''

        if invocation == self.cb:
            if self.callback is not None:
                self.callback(*args)

                del deferredList[self.cb]
                del deferredList[self.eb]

        elif invocation == self.eb:
            if self.errback is not None:
                self.errback(*args)

                del deferredList[self.cb]
                del deferredList[self.eb]

        else:
            riffle.Error("Deferred unable to process invocation " + str(invocation))


class App(object):

    def __init__(self):
        self.deferreds, self.registrations, self.subscriptions = {}, {}, {}

    def recv(self, domain):
        while True:
            i, args = json.loads(domain.Receive())
            args = [] if args is None else args

            # Turned out to work as a leave case, though this isn't clean
            if i == 0:
                break

            # print "Received invocation " + str(i) + " with args " + str(args)
            # print "Current deferrds: " + str(self.deferreds)

            if i in self.deferreds:
                d = self.deferreds[i]

                # TODO: throw exception down the wire
                results = d._invoke(self.deferreds, i, args)

                # Check if this is a registration and yield if so
                if d.hn == i and d.isRegistration:
                    pass

            elif i in self.registrations:
                pass

            elif i in self.subscriptions:
                pass

                # This is a registration
                # if results is not None:
                #     pass
            else:
                riffle.Debug("Invocation not found in handlers, subscriptions, or registrations for id" + str(i))

            # Wrap it all in a try-catch, return publish and call errors
            # Don't return yield errors-- its not clear who should deal with those

            # Possible remove meta on completion
            # if i in self.control:
            #     self.control[i](*args)

            # elif i in self.subscriptions:
            #     self.subscriptions[i](*args)

            # Remove results on completion
            # elif i in self.results:
            #     self.results[i](*args)

            # elif i in self.registrations:
            #     returnId = args.pop(0)

            #     ret = self.registrations[i](*args)
            #     ret = [] if ret is None else ret

            #     if not isinstance(ret, (list, tuple)):
            #         ret = [ret]

            #     domain.Yield(returnId, json.dumps(ret))

            # else:
            #     riffle.Error("No handler available for " + str(i))


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
        d = Deferred()
        d.callback = self.onJoin

        self.app.deferreds[d.cb], self.app.deferreds[d.eb] = d, d
        self.mantleDomain.Join(d.cb, d.eb)

        # Make this explicit by putting it in its own method?
        # This is partially covered by whatever new login system gets done
        self.app.recv(self.mantleDomain)

    def onJoin(self):
        riffle.Info("Default onJoin")

    def onLeave(self):
        riffle.Info("Default onLeave")

    def subscribe(self, endpoint, handler):
        d = Deferred()
        d.handler = handler

        self.app.deferreds[d.cb], self.app.deferreds[d.eb], self.app.deferreds[d.hn] = d, d, d
        self.mantleDomain.Subscribe(endpoint, d.cb, d.eb, d.hn, json.dumps([]))

    def register(self, endpoint, handler):
        d = Deferred(isRegistration=True)
        d.handler = handler

        self.app.deferreds[d.cb], self.app.deferreds[d.eb], self.app.deferreds[d.hn] = d, d, d
        self.mantleDomain.Register(endpoint, d.cb, d.eb, d.hn, json.dumps([]))

    def publish(self, endpoint, *args):
        cb, eb = newID(2)
        self.mantleDomain.Publish(endpoint, cb, eb, json.dumps(args))

    def call(self, endpoint, handler, *args):
        d = Deferred()

        self.app.deferreds[d.cb], self.app.deferreds[d.eb] = d, d
        self.mantleDomain.Call(endpoint, cb, eb, json.dumps(args), json.dumps([]))

    def leave(self):
        self.mantleDomain.Leave()

'''
Top level interface into Riffle library. The crust sits atop the mantle, which sits atop the core. 
The mantle is imported here as pymantle. It doesn't add functionality on top of the core, just
translates between coreRiffle and python as needed. 

'''

import os
import json

from greenlet import greenlet

import pymantle
from riffle import cumin, utils


class Domain(object):

    def __init__(self, name, superdomain=None, sibling=None):
        self.name = name

        if superdomain is not None:
            self.mantleDomain = superdomain.mantleDomain.Subdomain(name)
            self.app = superdomain.app
        elif sibling is not None:
            self.mantleDomain = sibling.mantleDomain.LinkDomain(name)
            self.app = sibling.app
        else:
            self.mantleDomain = pymantle.NewDomain(name)
            self.app = App()

    def join(self, token=None):
        # Pass credentials down to the core before attempting to join the
        # fabric.
        if token is not None:
            self.mantleDomain.SetToken(token)

        # TODO: convert the "control plane" to use deferreds using Twisted style callbacks
        cb, eb = utils.newID(2)
        self.app.control[cb] = self.onJoin
        self.mantleDomain.Join(cb, eb)

        self.app.mainGreenlet = greenlet(self.app.handle)
        self.app.mainGreenlet.switch(self.mantleDomain)

    def leave(self):
        # TODO: Emit a deferred here (?)
        self.mantleDomain.Leave()

    def onJoin(self):
        pymantle.Info("Default onJoin")

    def onLeave(self):
        pymantle.Info("Default onLeave")

    def subscribe(self, endpoint, handler):
        return self._setHandler(endpoint, handler, self.mantleDomain.Subscribe, False)

    def register(self, endpoint, handler):
        return self._setHandler(endpoint, handler, self.mantleDomain.Register, True)

    def publish(self, endpoint, *args):
        return self._invoke(endpoint, args, self.mantleDomain.Publish, False)

    def call(self, endpoint, *args):
        return self._invoke(endpoint, args, self.mantleDomain.Call, True)

    def _setHandler(self, endpoint, handler, coreFunction, doesReturn):
        '''
        Register or Subscribe. Invokes targetFunction for the given endpoint and handler.

        :param coreFunction: the intended core function, either Subscribe or Register
        :param doesReturn: True if this handler can return a value (is a registration)
        '''

        d, handlerId = Deferred(), utils.newID()
        self.app.deferreds[d.cb], self.app.deferreds[d.eb] = d, d
        self.app.handlers[handlerId] = handler, doesReturn

        coreFunction(endpoint, d.cb, d.eb, handlerId, cumin.reflect(handler))
        return d

    def _invoke(self, endpoint, args, coreFunction, doesReturn):
        '''
        Publish or Call. Invokes targetFunction for the given endpoint and handler.

        :param coreFunction: the intended core function, either Subscribe or Register
        :param doesReturn: True if this handler can receive results (is a call)
        '''

        d = Deferred()
        d.canReturn = doesReturn
        d.mantleDomain = self.mantleDomain
        self.app.deferreds[d.cb], self.app.deferreds[d.eb] = d, d

        coreFunction(endpoint, d.cb, d.eb, cumin.marshall(args))
        return d

    def link(self, name):
        """
        Access another domain.

        Returns a new Domain object with the given name, which should
        be fully-qualified (e.g. "xs.demo.user.app.Storage").
        """
        return Domain(name, sibling=self)


class Deferred(object):

    def __init__(self):
        self.cb, self.eb = utils.newID(2)
        self.green = None

        # Boy does it hurt me to put this here. canReturn needs to have access to the domain
        # for call returns
        self.mantleDomain = None

        # True if this deferred should inform the core of its types once set
        # Only true for calls
        self.canReturn = False

    def wait(self, *types):
        ''' Wait until the results of this invocation are resolved '''

        # if canReturn then this is a call. We need to retroactively inform the core of our types
        if self.canReturn:
            self.mantleDomain.CallExpects(self.cb, cumin.prepareSchema(types))

        # Get our current greenlet. If we're not running in a greenlet, someone screwed up bad
        self.green = greenlet.getcurrent()

        # Switch back to the parent greenlet: block until the parent has time to resolve us
        results = self.green.parent.switch(self)

        if isinstance(results, Exception):
            raise results

        r = cumin.unmarshall(results, types)

        # Actually, this cant happen. A return from a function should always come back as
        # a list. Unless you mean a return from... any other thing. In which case, bleh.
        if r is None:
            return r

        return r[0] if len(r) == 1 else r

    def setCallback(self, handler):
        ''' Traditional Twisted style callbacks '''
        pass


class App(object):

    def __init__(self):
        # self.handlers contains a tuple of (function, bool), where the bool is True if the
        # function can return (i.e. is a registration)
        self.deferreds, self.handlers, self.control = {}, {}, {}
        self.mainGreenlet = None

    def handle(self, domain):
        ''' Open connection with the core and begin handling callbacks '''

        while True:
            i, args = json.loads(domain.Receive())
            args = [] if args is None else args

            # When the channel that feeds the Receive function closes, 0 is returned
            # This is currently automagic and happened to work on accident, but consider
            # a more explicit close
            if i == 0:
                break

            if i in self.deferreds:
                d = self.deferreds[i]
                del self.deferreds[d.cb]
                del self.deferreds[d.eb]

                # Special Python case-- if this is an errback construct an excepction
                if i == d.eb:
                    args = utils.Error(*args)

                # Deferreds are always emitted by async methods. If the user called .wait()
                # then the deferred instantiates a greenlet as .green. Resume that greenlet.
                # If that greenlet emits another deferred the user has called .wait() again.
                if d.green is not None:
                    d = d.green.switch(args)
                    if d is not None:
                        self.deferreds[d.cb], self.deferreds[d.eb] = d, d

            elif i in self.handlers:
                handler, canReturn = self.handlers[i]

                if canReturn:
                    resultID = args.pop(0)

                # Consolidated handlers into one
                try:
                    ret = handler(*args)
                except Exception as error:
                    # TODO: Differentiate Riffle errors vs. other exceptions,
                    # maybe reraise other exceptions.
                    if canReturn:
                        domain.YieldError(resultID, "wamp.error.runtime_error", json.dumps([str(error)]))
                    else:
                        print "An exception occured: ", error
                else:
                    if canReturn:
                        if ret is None:
                            ret = []
                        elif isinstance(ret, tuple):
                            ret = list(ret)
                        else:
                            ret = [ret]

                        domain.Yield(resultID, cumin.marshall(ret))

            # Control messages. These should really just be deferreds, but not implemented yet
            if i in self.control:
                d = greenlet(self.control[i]).switch(*args)

                # If user code called .wait(), this deferred is emitted, waiting on the results of some operation
                if d is not None:
                    self.deferreds[d.cb], self.deferreds[d.eb] = d, d

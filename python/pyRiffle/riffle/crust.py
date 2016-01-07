'''
Top level interface into Riffle library. The crust sits atop the mantle, which sits atop the core. 
The mantle is imported here as pymantle. It doesn't add functionality on top of the core, just
translates between coreRiffle and python as needed. 

I made a mistake. Deferreds should only cover success/failure callbacks, while the handlers
are only for register/subscribe

Fixing the osx python version: 
    https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/Common-Issues.md#python-segmentation-fault-11-on-import-some_python_module
'''

import os
import json

from greenlet import greenlet

import pymantle
from riffle.cumin import cuminReflect
from riffle.model import Model, reconstruct
from riffle.utils import newID


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

        self.app.green = greenlet(self.app.handle)
        self.app.green.switch(self.mantleDomain)
    
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
        return self._invoke(endpoint, args, self.mantleDomain.Publish)

    def call(self, endpoint, *args):
        return self._invoke(endpoint, args, self.mantleDomain.Call)

    def _setHandler(self, endpoint, handler, coreFunction, doesReturn):
        '''
        Register or Subscrive. Invokes targetFunction for the given endpoint and handler.

        :param coreFunction: the intended core function, either Subscribe or Register
        :param doesReturn: True if this handler can return a value (is a registration)
        ''' 

        d, handlerId = Deferred(), newID()
        self.app.deferreds[d.cb], self.app.deferreds[d.eb] = d, d
        self.app.handlers[handlerId] = handler, doesReturn

        coreFunction(endpoint, d.cb, d.eb, handlerId, json.dumps(cuminReflect(handler)))
        return d

    def _invoke(self, endpoint, args, coreFunction): 
        '''
        Publish or Call. Invokes targetFunction for the given endpoint and handler.

        :param coreFunction: the intended core function, either Subscribe or Register
        '''
        d = Deferred()
        self.app.deferreds[d.cb], self.app.deferreds[d.eb] = d, d
        coreFunction(endpoint, d.cb, d.eb, json.dumps(args))
        return d


class Deferred(object):

    def __init__(self):
        self.cb, self.eb = newID(2)
        self.green = None

    def wait(self, *types):
        ''' Wait until the results of this invocation are resolved '''

        # Get our current greenlet. If we're not running in a greenlet, someone screwed up bad
        self.green = greenlet.getcurrent()

        # Switch back to the parent greenlet: block until the parent has time to resolve us
        results = self.green.parent.switch(self)
        r = reconstruct(results, types)

        # if isinstance(Exception), raise exception

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
        self.deferreds, self.handlers, self.control = {}, {}, {}

        # The greenlet that runs the handle loop
        self.green = None

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
                    #
                    # I hard-coded "wamp.error.internal_error" for now because
                    # we cannot tell the cause of the error yet.
                    if canReturn:
                        domain.YieldError(resultID, "Exception in handler", json.dumps([str(error)]))
                else:
                    if canReturn:
                        ret = [] if ret is None else ret
                        if not isinstance(ret, (list, tuple)):
                            ret = [ret]

                        domain.Yield(resultID, json.dumps(ret))

            # Control messages. These should really just be deferreds, but not implemented yet
            if i in self.control:
                d = greenlet(self.control[i]).switch(*args)

                # If user code called .wait(), this deferred is emitted, waiting on the results of some operation
                if d is not None:
                    self.deferreds[d.cb], self.deferreds[d.eb] = d, d

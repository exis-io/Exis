'''
Autobahn examples using vanilla WAMP
'''

from os import environ
from twisted.internet import reactor
from twisted.internet.defer import inlineCallbacks

from autobahn.twisted.wamp import ApplicationSession, ApplicationRunner


class Component(ApplicationSession):

    """
    Application component that calls procedures which
    produce complex results and showing how to access those.
    """

    @inlineCallbacks
    def onJoin(self, details):
        print("session attached")

        res = yield self.call('xs.testerer/hello', 2, 3)
        # print 'Called add with 2 + 3 = ', res

        # print 'Asking the other guy to die'
        # res = yield self.call('pd.damouse/kill')

        # yield self.subscribe(self.pong, 'pd/pong')
        # yield self.publish('pd/ping')

        self.leave()

    def onDisconnect(self):
        print("disconnected")
        reactor.stop()

    def pong(self):
        print 'Pong! Server was able to route the message in!'
        self.leave()


if __name__ == '__main__':
    runner = ApplicationRunner(
        environ.get("AUTOBAHN_DEMO_ROUTER", "ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws"),
        u"pd.dale",
        debug_wamp=False,  # optional; log many WAMP details
        debug=False,  # optional; log even more details
    )

    runner.run(Component)

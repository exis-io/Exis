'''
Autobahn examples using vanilla WAMP
'''

from os import environ
from twisted.internet.defer import inlineCallbacks
from twisted.internet import reactor

from autobahn.wamp.types import CallResult
from autobahn.twisted.wamp import ApplicationSession, ApplicationRunner


def hasPermission():
    print 'Query for a permission'
    return True


class Component(ApplicationSession):

    """
    Application component that provides procedures which
    return complex results.
    """

    @inlineCallbacks
    def onJoin(self, details):
        print "Bouncer attached"

        yield self.register(hasPermission, 'pd.bouncer/checkPerm')


if __name__ == '__main__':
    runner = ApplicationRunner(
        "ws://127.0.0.1:8000/ws",
        # "ws://paradrop.io:8000/ws",
        u"pd.bouncer",
        debug_wamp=False,  # optional; log many WAMP details
        debug=False,  # optional; log even more details
    )

    runner.run(Component)

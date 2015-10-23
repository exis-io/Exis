import time

from twisted.internet import reactor
from twisted.internet.defer import inlineCallbacks, returnValue

from autobahn.wamp.types import CallOptions, PublishOptions
from autobahn.twisted.wamp import ApplicationSession, ApplicationRunner

from pdtools.lib import cxbr

HOST = "ws://127.0.0.1:8000/ws"
# HOST = "ws://paradrop.io:9080/ws"


class Client(cxbr.BaseSession):

    @inlineCallbacks
    def onJoin(self, details):
        ret = yield self.call('pd', 'call', 'args')
        print ret

        ret = yield self.publish('pd', 'sub')
        print 'Completed publication'

        # as currently built this MUST be called at the end of onJoin, not at the start!
        yield cxbr.BaseSession.onJoin(self, details)
        self.leave()

    def onDisconnect(self):
        print "disconnected"
        reactor.stop()


@inlineCallbacks
def makeSession():
    '''
    This method demonstrates how to start a session 'in-line,' or making the session 
    and then retrieveing it as a deferred
    '''
    session = yield Client.start(HOST, 'pd.tester')

    # This is useful, and that should be obvious-- under the standard initialization
    # behavior the sessions can't interact with the code that started them until they boot
    # up. This added functionality allows for that.
    print 'Got session ' + str(session)
    print '--Calling session methods externally'
    ret = yield session.call('pd', 'call', 12)
    print ret


def main():
    # Method 1- start the session and pass start_reactor=True (which is non-standard behavior.)
    # It will block, start the reactor, and pass all authority to the session.
    Client.start(HOST, 'pd.damouse', start_reactor=True)

    # Method 2- instead of starting the client and letting it manage its own operation,
    # create a session and run methods externally. NOTE: This is not completely
    # implemented now, since onJoin calls 'self.leave()' at the end, which messes
    # with the external calls. Normally you shouldn't make the call there.
    # reactor.callLater(.1, makeSession)
    # reactor.run()

    # Method 3- In the case where you're going to make a quick pub or sub that
    # you don't need to make oop, all pub and sub calls can be executed on the
    # base object. This is used in practice in pdtools
    # sess = yield cxbr.BaseSession.start("ws://127.0.0.1:8080/ws", 'pd.damouse')
    # yield sess.call('pd', 'call', 12)


if __name__ == '__main__':
    main()

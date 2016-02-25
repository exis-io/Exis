#
# Implements a synchronous fabric session with timeouts for repeatable testing.
#
# Creating an instance of SyncSession and calling join on it will spawn a new
# process to encapsulate the fabric session.  All commands and data are
# exchanged by passing messages through Queues from the multiprocessing
# library.
#
# Operations such as join and call will block with an optional timeout in
# seconds (as a float).  One should always set the timeout for testing to
# ensure eventual completion of the tests.  Operations on a SyncSession
# instance are NOT thread safe, but you can safely use multiple SyncSession
# instances.  Exceptions are generally used to indicate error conditions,
# including timeouts.
#


import multiprocessing
import os

class SyncSession(object):
    def __init__(self, node, domain, timeout=None, key=None, token=None):
        """
        node: websocket url for node
        domain: domain to use when connecting to the fabric
        timeout: default timeout for operations in seconds
        """
        self.node = node
        self.domain = domain
        self.timeout = timeout
        self.key = key
        self.token = token

        self.process = None
        self.incoming = multiprocessing.Queue()
        self.outgoing = multiprocessing.Queue()

    def join(self, timeout=None):
        if timeout is None:
            timeout = self.timeout

        self.process = multiprocessing.Process(target=riffle_main,
                args=(self.outgoing, self.incoming, self.node, self.domain, self.key, self.token))
        self.process.daemon = True   # True means it will die if the parent exits
        self.process.start()

        result = self.incoming.get(True, timeout)
        if result[0] != "JOINED":
            raise Exception("Unexpected result for join")

    def leave(self):
        self.outgoing.put(("LEAVE", ))

    def call(self, *args, **kwargs):
        self.outgoing.put(("CALL", args))
        timeout = kwargs.get("timeout", self.timeout)
        result = self.incoming.get(True, timeout)
        if result[0] == "YIELD":
            return result[1]
        elif result[0] == "ERROR":
            raise Exception(result[1])
        else:
            raise Exception("Unexpected result for call")

    def publish(self, *args, **kwargs):
        self.outgoing.put(("PUBLISH", args))
        timeout = kwargs.get("timeout", self.timeout)
        result = self.incoming.get(True, timeout)
        if result[0] == "PUBLISHED":
            return
        elif result[0] == "ERROR":
            raise Exception(result[1])
        else:
            raise Exception("Unexpected result for publish")


#
# This is the main function of the child process.
#
# We intentionally import riffle and define the Domain class inside this
# function where it is encapsulated in the child process.
#
def riffle_main(incoming, outgoing, node, domain, key, token):
    import riffle

    class MyDomain(riffle.Domain):
        def onJoin(self):
            outgoing.put(("JOINED", ))
            while True:
                command = incoming.get()
                if command[0] == "LEAVE":
                    break
                elif command[0] == "CALL":
                    try:
                        result = self.call(*command[1]).wait(None)
                        outgoing.put(("YIELD", result))
                    except Exception as error:
                        outgoing.put(("ERROR", str(error)))
                elif command[0] == "PUBLISH":
                    try:
                        result = self.publish(*command[1]).wait()
                        outgoing.put(("PUBLISHED", ))
                    except Exception as error:
                        outgoing.put(("ERROR", str(error)))
            self.leave()

    riffle.SetFabric(node)
    domain = MyDomain(domain)
    domain.join(token=token)

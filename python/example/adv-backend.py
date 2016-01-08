# Template Setup
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class GenericDomain(riffle.Domain):

    def onJoin(self):
        # End Template Setup

        ######################################################
        # TODO this would be an advanced setup to show how leave would work
        class Logger(riffle.Domain):
            @want([str])
            def pushLogs(self, l):
                self.logs.extend(l)

            def pullLogs(self):
                return self.logs

            def onJoin(self):
                self.logs = list()
                self.subscribe("pushLogs", self.pushLogs)
                @want(str)
                def alive(s):
                    print s # Expects a str, like "Still alive?"
                    return "Yes"
                self.register("alive", alive)
                self.register("pullLogs", self.pullLogs)
        
        # TODO this code should work but it doesn't - basically
        # it should trigger the onJoin() but it doesn't. Also
        # calling self.logger.join() or self.logger.onJoin() doesn't
        # work b/c of differnet errors we see in the go core
        self.logger = Logger("logger", superdomain=app)
        
        self.register("done", self.loggerDone)

    @want(bool)
    def loggerDone(self, b):
        print b # Expects a bool, like True
        if b:
            self.logger.leave()
        return True


# Template Setup
app = riffle.Domain("xs.demo.test")

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("backend", superdomain=app).join()
# End Template Setup

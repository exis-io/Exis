# Template Setup
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class GenericDomain(riffle.Domain):

    def onJoin(self):
        # End Template Setup
        ######################################################################################
        # Example Test Restart before call - Does restarting before a call work?
        @want(str)
        def restartBeforeC(s):
            print(s) # Expects a str, like "Restart before call"
            return "{} works".format(s)
        self.register("restartBeforeC", restartBeforeC)
        # End Example Test Restart before call
        
        # Example Test Restart after reg - Does restarting after a register work
        import time
        @want(str)
        def restartAfterR(s):
            print(s) # Expects a str, like "Restart after reg"
            return "{} works".format(s)
        self.register("restartAfterR", restartAfterR)
        time.sleep(1.0)
        print "___NODERESTART___"
        time.sleep(2.0)
        # End Example Test Restart after reg

        print "___SETUPCOMPLETE___"


# Template Setup
app = riffle.Domain("xs.demo.test")

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("backend", superdomain=app).join()
# End Template Setup

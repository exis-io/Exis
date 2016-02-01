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
        import time
        # Trying to restart the node before the call happens, but need to insert artificial delay to make this happen!
        print "___NODERESTART___"
        time.sleep(4.0)
        s = backend.call("restartBeforeC", "Restart before call").wait(str)
        print(s) # Expects a str, like "Restart before call works"
        # End Example Test Restart before call
        
        # Example Test Restart after reg - Does restarting after a register work
        import time
        time.sleep(2.0)
        s = backend.call("restartAfterR", "Restart after reg").wait(str)
        print(s) # Expects a str, like "Restart after reg works"
        # End Example Test Restart after reg

        print "___SETUPCOMPLETE___"

# Template Setup
app = riffle.Domain("xs.demo.test") # ARBITER $DOMAIN replaces "xs.demo.test"

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("client", superdomain=app).join() # ARBITER $SUBDOMAIN replaces "client"
# End Template Setup

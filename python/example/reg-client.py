# Template Setup
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class GenericDomain(riffle.Domain):

    def onJoin(self):
        # End Template Setup
        
        # Example Reg/Call - This is a basic reg/call
        backend.call("reg", "Hi").wait()
        # End Example Reg/Call

        # Example Reg/Call Basic 1 - This is a basic reg/call
        # Make the call
        s = backend.call("basicReg1", "Hello").wait(str)
        print(s)  # Expects a string, like "Hello World"
        # End Example Reg/Call Basic 1

        # Example Reg/Call Basic 2 - This is a basic reg/call
        print(backend.call("basicReg2", "Hello").wait(str))  # Expects a string, like "Hello World"
        # End Example Reg/Call Basic 2

        print "___SETUPCOMPLETE___"

# Template Setup
app = riffle.Domain("xs.demo.test") # ARBITER $DOMAIN replaces "xs.demo.test"

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("client", superdomain=app).join() # ARBITER $SUBDOMAIN replaces "client"
# End Template Setup

# Template Setup
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class GenericDomain(riffle.Domain):

    def onJoin(self):
        # End Template Setup
        ######################################################################################
        # Example Test Reg/Call Big Ints - should be big
        i = backend.call("sendBigInt", 9223372036854775807).wait(int)
        print("{:d}".format(int(i))) # Expects a str, like "9223372036854775807"
        # End Example Test Reg/Call Big Ints

        print "___SETUPCOMPLETE___"

# Template Setup
app = riffle.Domain("xs.demo.test") # ARBITER $DOMAIN replaces "xs.demo.test"

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("client", superdomain=app).join() # ARBITER $SUBDOMAIN replaces "client"
# End Template Setup

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
        @want(int)
        def sendBigInt(i):
            print("{:d}".format(int(i))) # Expects a str, like "9223372036854775807"
            return i
        self.register("sendBigInt", sendBigInt)
        # End Example Test Reg/Call Big Ints

        print "___SETUPCOMPLETE___"


# Template Setup
app = riffle.Domain("xs.demo.test")

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("backend", superdomain=app).join()
# End Template Setup

# Template Setup
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class GenericDomain(riffle.Domain):

    def onJoin(self):
        # End Template Setup
        
        # Example Tour Basics 1 - simple print
        # ARBITER set action simple
        print "Hello World"
        # End Example Tour Basics 1
        
        # Example Tour Basics 2 - async NOTE this code won't run since pub/sub is in line
        @want(int)
        def async(i):
            print i
        self.subscribe("async", async)
        # End Example Tour Basics 2
        
        # Example Tour Basics 2 - async NOTE this code won't run since pub/sub is in line
        for i in range(0, 10):
            backend.publish("async", i)
        # End Example Tour Basics 2
        
        

        print "___SETUPCOMPLETE___"

# Template Setup
app = riffle.Domain("xs.demo.test") # ARBITER $DOMAIN replaces "xs.demo.test"

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("client", superdomain=app).join() # ARBITER $SUBDOMAIN replaces "client"
# End Template Setup

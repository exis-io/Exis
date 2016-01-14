# Template Setup
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class GenericDomain(riffle.Domain):

    def onJoin(self):
        # End Template Setup
        
        ######################################################################################
        # Example Tour Pub/Sub Lesson 1 - our first basic example
        backend.publish("myFirstSub", "Hello")
        # End Example Tour Pub/Sub Lesson 1

        ######################################################################################
        # Example Tour Pub/Sub Lesson 2 Works - type enforcement good
        backend.publish("iWantStrings", "Hi")
        # End Example Tour Pub/Sub Lesson 2 Works
        
        # Example Tour Pub/Sub Lesson 2 Fails - type enforcement bad
        backend.publish("iWantInts", "Hi")
        # End Example Tour Pub/Sub Lesson 2 Fails
        

        print "___SETUPCOMPLETE___"

# Template Setup
app = riffle.Domain("xs.demo.test") # ARBITER $DOMAIN replaces "xs.demo.test"

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("client", superdomain=app).join() # ARBITER $SUBDOMAIN replaces "client"
# End Template Setup

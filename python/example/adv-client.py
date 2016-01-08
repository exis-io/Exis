# Template Setup
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class GenericDomain(riffle.Domain):

    def onJoin(self):
        # End Template Setup

        logger = riffle.Domain("logger", superdomain=app)
        
        # Check if its alive
        s = logger.call("alive", "Still alive?").wait(str)
        print s # Expects a str, like "Yes"
        
        logger.publish("pushLogs", ["A", "B"])
        
        # Check if its alive
        s = logger.call("alive", "Still alive?").wait(str)
        print s # Expects a str, like "Yes"

        logs = logger.call("pullLogs", True).wait(list(str))
        print logs # Expects a list(str), like ["A", "B"]
        
        res = backend.call("done", True).wait(bool)
        print res # Expects a bool, like True
        
        # Check if its alive
        s = logger.call("alive", "Still alive?").wait(str)
        print s # Expects a str, like "Yes"
        

# Template Setup
app = riffle.Domain("xs.demo.test")

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("client", superdomain=app).join()
# End Template Setup

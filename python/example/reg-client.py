# Template Setup
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class GenericDomain(riffle.Domain):

    def onJoin(self):
        # End Template Setup
        
        # Example Reg/Call str str - Basic reg expects string, returns string
        s = backend.call("regStrStr", "Hello").wait(str)
        print s # Expects a str, like "Hello World"
        # End Example Reg/Call str str
        
        # Example Reg/Call str int - Basic reg expects string, returns int
        i = backend.call("regStrInt", "Hello").wait(int)
        print i # Expects an int, like 42
        # End Example Reg/Call str int
        
        # Example Reg/Call int str - Basic reg expects int, returns str
        s = backend.call("regIntStr", 42).wait(str)
        print s # Expects a str, like "Hello World"
        # End Example Reg/Call int str
        

        print "___SETUPCOMPLETE___"

# Template Setup
app = riffle.Domain("xs.demo.test") # ARBITER $DOMAIN replaces "xs.demo.test"

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("client", superdomain=app).join() # ARBITER $SUBDOMAIN replaces "client"
# End Template Setup

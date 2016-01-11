# Template Setup
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class GenericDomain(riffle.Domain):

    def onJoin(self):
        # End Template Setup
        
        # Example Tour Reg/Call Lesson 1 - our first basic example
        s = backend.call("myFirstCall", "Hello").wait(str)
        print s # Expects a str, like "Hello World"
        # End Example Tour Reg/Call Lesson 1
        
        # Example Tour Reg/Call Lesson 2 Works - type enforcement good
        s = backend.call("iWantStrings", "Hi").wait(str)
        print s # Expects a str, like "Thanks for saying Hi"
        # End Example Tour Reg/Call Lesson 2 Works
        
        # Example Tour Reg/Call Lesson 2 Fails - type enforcement bad
        try:
            s = backend.call("iWantInts", "Hi").wait(str)
            print s # Expects a str, like "Thanks for sending int 42"
        except riffle.Error as e:
            print e # Errors with "Cumin: expecting primitive int, got string"
        # End Example Tour Reg/Call Lesson 2 Fails
        
        # Example Tour Reg/Call Lesson 2 Wait Check - type enforcement on wait
        try:
            s = backend.call("iGiveInts", "Hi").wait(str)
            print s # Expects a str, like "Hello"
        except riffle.Error as e:
            print e # Errors with "Cumin: expecting primitive int, got string"
        # End Example Tour Reg/Call Lesson 2 Wait Check
        
        # Example Tour Reg/Call Lesson 3 Works - collections of types
        s = backend.call("iWantManyStrings", ["This", "is", "cool"]).wait(str)
        print s # Expects a str, like "Thanks for 3 strings!"
        # End Example Tour Reg/Call Lesson 3 Works
        
        # Example Tour Reg/Call Lesson 3 Fails - collections of types
        try:
            s = backend.call("iWantManyInts", [0, 1, "two"]).wait(str)
            print s # Expects a str, like "Thanks for 3 ints!"
        except riffle.Error as e:
            print e # Errors with "Cumin: expecting primitive int, got string"
        # End Example Tour Reg/Call Lesson 3 Fails
        

        print "___SETUPCOMPLETE___"

# Template Setup
app = riffle.Domain("xs.demo.test") # ARBITER $DOMAIN replaces "xs.demo.test"

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("client", superdomain=app).join() # ARBITER $SUBDOMAIN replaces "client"
# End Template Setup

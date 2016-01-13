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
        @want(str)
        def myFirstSub1(s):
            print("I got {}".format(s))  # Expects a str, like "I got Hello"
        self.subscribe("myFirstSub", myFirstSub1)
        # Somewhere in another file or program...
        @want(str)
        def myFirstSub2(s):
            print("I got {}, too!".format(s))  # Expects a str, like "I got Hello, too!"
        self.subscribe("myFirstSub", myFirstSub2)
        # End Example Tour Pub/Sub Lesson 1
        
        ######################################################################################
        # Example Tour Pub/Sub Lesson 2 Works - type enforcement good
        @want(str)
        def iWantStrings(s):
            print(s)  # Expects a str, like "Hi"
        self.subscribe("iWantStrings", iWantStrings)
        # End Example Tour Pub/Sub Lesson 2 Works
        
        # Example Tour Pub/Sub Lesson 2 Fails - type enforcement bad
        @want(int)
        def iWantInts(i):
            # This function isn't called
            print("You won't see me :)")
        self.subscribe("iWantInts", iWantInts)
        # End Example Tour Pub/Sub Lesson 2 Fails
        
        
        print "___SETUPCOMPLETE___"
        

# Template Setup
app = riffle.Domain("xs.demo.test")

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("backend", superdomain=app).join()
# End Template Setup

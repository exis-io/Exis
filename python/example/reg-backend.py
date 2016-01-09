# Template Setup
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class GenericDomain(riffle.Domain):

    def onJoin(self):
        # End Template Setup
        # Example Reg/Call - This is a basic reg/call, with no response
        @want(str)
        def reg(s):
            print(s)  # Expects a string, like "Hi"
        self.register("reg", reg)
        # End Example Reg/Call

        # Example Reg/Call Basic 1 - This is a basic reg/call
        def basicReg1(s):
            print(s)  # Expects a string, like "Hello"
            return "{} World".format(s), 3
        self.register("basicReg1", basicReg1)
        # End Example Reg/Call Basic 1

        # Example Reg/Call Basic 2 - This is a basic reg/call
        def basicReg2(s):
            print(s)  # Expects a string, like "Hello"
            return "{} World".format(s)
        self.register("basicReg2", basicReg2)
        # End Example Reg/Call Basic 2
        
        print "___SETUPCOMPLETE___"
        

# Template Setup
app = riffle.Domain("xs.demo.test")

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("backend", superdomain=app).join()
# End Template Setup

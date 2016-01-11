# Template Setup
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class GenericDomain(riffle.Domain):

    def onJoin(self):
        # End Template Setup
        # Example Reg/Call str str - Basic reg expects string, returns string
        @want(str)
        def regStrStr(s):
            print(s)  # Expects a str, like "Hello"
            return "Hello World"
        self.register("regStrStr", regStrStr)
        # End Example Reg/Call str str
        
        # Example Reg/Call str int - Basic reg expects string, returns int
        @want(str)
        def regStrInt(s):
            print(s)  # Expects a str, like "Hello"
            return 42
        self.register("regStrInt", regStrInt)
        # End Example Reg/Call str int
        
        # Example Reg/Call int str - Basic reg expects int, returns str
        @want(int)
        def regIntStr(i):
            print(i)  # Expects an int, like 42
            return "Hello World"
        self.register("regIntStr", regIntStr)
        # End Example Reg/Call int str
        
        print "___SETUPCOMPLETE___"
        

# Template Setup
app = riffle.Domain("xs.demo.test")

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("backend", superdomain=app).join()
# End Template Setup


import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class Send(riffle.Domain):
    def onJoin(self):
        # Example Reg/Call - This is a basic reg/call
        beta.call("reg", "Hi").wait()
        # End Example Reg/Call
        
        # Example Reg/Call Basic 1 - This is a basic reg/call
        # Make the call
        s = beta.call("basicReg1", "Hello").wait()
        print(s) # Expects a string, like "Hello World"
        # End Example Reg/Call Basic 1
        
        # Example Reg/Call Basic 2 - This is a basic reg/call
        print(beta.call("basicReg2", "Hello").wait()) # Expects a string, like "Hello World"
        # End Example Reg/Call Basic 2
        

        # TODO: need to get leave working
        #app.leave()
        #beta.leave()
        #self.leave()


app = riffle.Domain("xs.damouse")
beta = riffle.Domain("beta", superdomain=app)

if __name__ == '__main__':
    Send("alpha", superdomain=app).join()
    exit()

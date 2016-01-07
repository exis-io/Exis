
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()


class Send(riffle.Domain):

    def onJoin(self):
        # Example Reg/Call - This is a basic reg/call
        self.call("reg", "Hi").wait()
        # End Example Reg/Call

        # Example Reg/Call Basic 1 - This is a basic reg/call
        # Make the call
        s = self.call("basicReg1", "Hello").wait(str)
        print(s)  # Expects a string, like "Hello World"
        # End Example Reg/Call Basic 1

        # Example Reg/Call Basic 2 - This is a basic reg/call
        print(self.call("basicReg2", "Hello").wait(str))  # Expects a string, like "Hello World"
        # End Example Reg/Call Basic 2

        self.leave()


app = riffle.Domain("xs.demo.test")
ex = riffle.Domain("example", superdomain=app)

if __name__ == '__main__':
    Send("example", superdomain=app).join()
    exit()

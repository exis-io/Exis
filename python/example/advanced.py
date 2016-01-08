# Template Setup
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class Send(riffle.Domain):

    def onJoin(self):
        # End Template Setup

        # TODO this would be an advanced setup to show how leave would work
        class Temp(riffle.Domain):
            def onJoin(self):
                logs = list()
                @want(list(str))
                def getLogs(l):
                    print l # Expects a list(str), like ["A", "B"]
                    logs.extend(l)
                self.subscribe("logs", getLogs)
                
                @want(bool)
                def doneLogs(b):
                    print b # Expects a bool, like True
                    return logs
                self.register("done", doneLogs)
        # Create a temp domain
        t = Temp("temp", superdomain=app)

        # (another file) Send some data to it
        temp.publish("logs", ["A", "B"])


        # Example Reg/Call - This is a basic reg/call
        recv.call("reg", "Hi").wait()
        # End Example Reg/Call

        # Example Reg/Call Basic 1 - This is a basic reg/call
        # Make the call
        s = recv.call("basicReg1", "Hello").wait(str)
        print(s)  # Expects a string, like "Hello World"
        # End Example Reg/Call Basic 1

        # Example Reg/Call Basic 2 - This is a basic reg/call
        print(recv.call("basicReg2", "Hello").wait(str))  # Expects a string, like "Hello World"
        # End Example Reg/Call Basic 2

        self.leave()

# Template Setup
app = riffle.Domain("xs.demo.test")
recv = riffle.Domain("recv", superdomain=app)
Send("send", superdomain=app).join()
# End Template Setup

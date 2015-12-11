
import riffle

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()


app = riffle.Domain("xs.damouse")
alpha = riffle.Domain("alpha", superdomain=app)

class Receiver(riffle.Domain):

    def onJoin(self):
        print "Receiver Joined" 

        self.register("reg", self.registration)
        self.subscribe("sub", self.subscription)

    def registration(self, a, b):
        print "Received a call. Args: ", a, b
        return 42

    def subscription(self, name):
        print "Received a publish from", name

Receiver("beta", superdomain=app).join()
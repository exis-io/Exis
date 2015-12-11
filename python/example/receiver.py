
import riffle

riffle.SetFabricLocal()
riffle.SetLogLevelInfo()


app = riffle.Domain("xs.damouse")
alpha = riffle.Domain("alpha", superdomain=app)

class Receiver(riffle.Domain):

    def onJoin(self):
        print "Receiver Joined" 

        self.register("reg", self.registration)
        self.register("kill", self.kill)

        self.subscribe("sub", self.subscription)

    def registration(self, a, b):
        print "Received a call. Args: ", a, b
        return 42

    def subscription(self, name):
        print "Received a publish from", name

    def kill(self):
        print 'Asked to close. Leaving'

        self.leave() 

Receiver("beta", superdomain=app).join()
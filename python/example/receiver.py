
import riffle

riffle.SetLocalFabric()
riffle.SetLogLevelDebug()

class Receiver(riffle.Domain):

    def onJoin(self):
        print "Receiver Joined" 

        self.register("reg", self.registration)

        self.subscribe("sub", self.subscription)

    def registration(self):
        print "Received a call!"

    def subscription(self):
        print "Received a publish!"


Receiver("xs.damouse.b").join()

import riffle

riffle.SetLocalFabric()
riffle.SetLogLevelDebug()

class Receiver(riffle.Domain):

    def onJoin(self):
        print "Receiver Joined" 

        # self.register("reg", self.registration)
        self.subscribe("sub", self.subscription)

    def registration(self, bol):
        print "Received a call. Args: ", bol

    def subscription(self, name):
        print "Received a publish from", name


Receiver("xs.damouse.b").join()
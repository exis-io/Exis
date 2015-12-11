
import riffle

riffle.SetLocalFabric()
riffle.SetLogLevelDebug()

class Sender(riffle.Domain):

    def onJoin(self):
        print "Sender Joined" 

        # self.publish("xs.damouse.b/sub", "John")

        self.call("xs.damouse.b/reg", 1, 2)

Sender("xs.damouse.a").join()
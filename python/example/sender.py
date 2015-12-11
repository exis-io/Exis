
import riffle

riffle.SetLocalFabric()
riffle.SetLogLevelDebug()

class Sender(riffle.Domain):

    def onJoin(self):
        print "Sender Joined" 

        self.publish("xs.damouse.b/sub")

Sender("xs.damouse.a").join()
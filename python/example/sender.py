
import riffle

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class Sender(riffle.Domain):

    def onJoin(self):
        print "Sender Joined" 

        self.publish("xs.damouse.b/sub", "John")

        self.call("xs.damouse.b/reg", self.result, 1, 2)

    def result(self, ret):
        print 'Call returned with result: ', ret

Sender("xs.damouse.a").join()
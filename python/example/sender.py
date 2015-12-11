
import riffle

riffle.SetFabricLocal()
riffle.SetLogLevelInfo()

app = riffle.Domain("xs.damouse")
beta = riffle.Domain("beta", superdomain=app)

class Sender(riffle.Domain):

    def onJoin(self):
        print "Sender Joined" 

        beta.publish("sub", self.name)
        beta.call("reg", self.result, 1, 2)

    def result(self, ret):
        print 'Call returned with result: ', ret
        beta.call("kill", None)

Sender("alpha", superdomain=app).join()
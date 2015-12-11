
import riffle

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

app = riffle.Domain("xs.damouse")
# print 1
b = riffle.Domain("b", superdomain=app)
# print 2

class Sender(riffle.Domain):

    def onJoin(self):
        print "Sender Joined" 

        b.publish("sub", "John")

        b.call("reg", self.result, 1, 2)

    def result(self, ret):
        print 'Call returned with result: ', ret

Sender("a", superdomain=app).join()
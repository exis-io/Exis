
import riffle

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class Sender(riffle.Domain):

    def onJoin(self):
        print "Sender Joined" 
        beta.publish("sub", self.name)
        beta.call("reg", self.result, 1, 2)

    def result(self, ret):
        print 'Call returned with result: ', ret
        # beta.call("kill", None)

if __name__ == '__main__':
    app = riffle.Domain("xs.damouse")
    beta = riffle.Domain("beta", superdomain=app)
    Sender("alpha", superdomain=app).join()
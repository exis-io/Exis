
import riffle

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

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

        # Not ready. Leaves, but not cleanly
        # self.leave() 

if __name__ == '__main__':
    app = riffle.Domain("xs.damouse")
    alpha = riffle.Domain("alpha", superdomain=app)
    Receiver("beta", superdomain=app).join()
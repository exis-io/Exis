
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class Recv(riffle.Domain):
    def onJoin(self):
        # Example Pub/Sub Basic - This is a basic version of a pub/sub
        @want(str)
        def basicSub(s):
            print "[basicSub] Got: {}".format(s) # Expects a string, like "Hello"
            print("string", s)
        self.subscribe("basicSub", basicSub)
        # End Example Pub/Sub Basic
        
        # Example Pub/Sub Objects - This sub expects an object
        class Stuff(riffle.Model):
            name = "The name"
        @want(Stuff)
        def objectSub(o):
            print "[objectSub] Got: {}".format(repr(o)) # Expects an object, like Stuff
        self.subscribe("objectSub", objectSub)
        # End Example Pub/Sub Objects
        
        # Example Pub/Sub OOO Racey - This shows that pubs can arrive out of order unless you call .wait() on them
        @singlethread
        def oooRaceSub(i):
            print("[oooRaceSub] Got: {}".format(i))
        self.subscribe("oooRaceSub", oooRaceSub)
        # End Example Pub/Sub OOO Racey
        
        # Example Pub/Sub OOO Corrected - This shows that pubs will arrive in order because we called wait()
        def oooCorrectSub(i):
            print("[oooCorrectSub] Got: {}".format(i))
        self.subscribe("oooCorrectSub", oooCorrectSub)
        # End Example Pub/Sub OOO Corrected
            

if __name__ == '__main__':
    app = riffle.Domain("xs.damouse")
    alpha = riffle.Domain("alpha", superdomain=app)
    Recv("beta", superdomain=app).join()
    exit()


class User(riffle.Model):
    name = "John Doe"
    email = ''

    def sayHello(self, other):
        print 'Im ' + self.name + ', how are you, ' + other + '?'


class Receiver(riffle.Domain):

    def onJoin(self):
        print "Receiver Joined"

        self.register("reg", self.registration)
        self.register("kill", self.kill)

        self.subscribe("sub", self.subscription)
        self.subscribe("handshake", self.greeting)

    @want(int, int)
    def registration(self, a, b):
        print "Received a call. Args: ", a, b
        return 42

    @want(str)
    def subscription(self, name):
        print "Received a publish from", name

    @want(User)
    def greeting(self, other):
        print "Received a publish from", other

    def kill(self):
        print 'Asked to close. Leaving'

        # Not ready. Leaves, but not cleanly
        # self.leave()

if __name__ == '__main__':
    app = riffle.Domain("xs.damouse")
    alpha = riffle.Domain("alpha", superdomain=app)
    Receiver("beta", superdomain=app).join()

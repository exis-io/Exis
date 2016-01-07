
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()


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

if __name__ == '__main__':
    app = riffle.Domain("xs.damouse")
    alpha = riffle.Domain("alpha", superdomain=app)
    Receiver("beta", superdomain=app).join()

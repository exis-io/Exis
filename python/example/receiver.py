
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelInfo()


class User(riffle.Model):
    name = "John Doe"
    email = 'bil@gmail.com'

    def sayHello(self):
        print 'Im ' + self.name + ', email me at ' + self.email

class Receiver(riffle.Domain):

    def onJoin(self):
        print "Receiver Joined"

        self.register("reg", self.registration)
        self.subscribe("sub", self.subscription)
        self.subscribe("model", self.model)

    @want(int, int)
    def registration(self, a, b):
        print "Received a call. Args: ", a, b
        return 42

    @want(str)
    def subscription(self, name):
        print "Received a publish from", name

    @want(User)
    def model(self, other):
        print "Received a publish from", other
        other.sayHello()

if __name__ == '__main__':
    app = riffle.Domain("xs.damouse")
    alpha = riffle.Domain("alpha", superdomain=app)
    Receiver("beta", superdomain=app).join()

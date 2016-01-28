
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelInfo()


class User(riffle.ModelObject):
    name = "John Doe"
    email = 'bil@gmail.com'

    def sayHello(self):
        print 'Im ' + self.name + ', email me at ' + self.email


class Receiver(riffle.Domain):

    def onJoin(self):
        print "Receiver Joined"

        self.subscribe("1", self.subscription)

        self.register("2", self.registration)

        self.subscribe("none", self.none)
        # self.subscribe("model", self.model)

    @want(int, int)
    def registration(self, a, b):
        print "1: expecting 1, 2\t ", a, b
        return 42

    @want(str)
    def subscription(self, name):
        print "1: expecting 1\t", name

    @want(User)
    def model(self, other):
        print "Received a publish from", other
        other.sayHello()

    # Not putting a want allows everything
    def none(self, name):
        print name + " called me"

if __name__ == '__main__':
    app = riffle.Domain("xs.damouse")
    alpha = riffle.Domain("alpha", superdomain=app)
    Receiver("beta", superdomain=app).join()

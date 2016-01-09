
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()


class Recv(riffle.Domain):

    def onJoin(self):

        # Example Pub/Sub Basic - This is a basic version of a pub/sub
        @want(str)
        def basicSub(s):
            print s  # Expects a str, like "Hello"
        self.subscribe("basicSub", basicSub)
        # End Example Pub/Sub Basic

        # Example Pub/Sub Objects - This sub expects an object
        class Stuff(riffle.Model):
            name = ""
        @want(Stuff)
        def objectSub(o):
            print o  # Expects an object, like Stuff

        self.subscribe("objectSub", objectSub)
        # End Example Pub/Sub Objects


if __name__ == '__main__':
    app = riffle.Domain("xs.demo.test")
    Recv("example", superdomain=app).join()
    exit()


import riffle

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()


class Beta(object):

    """docstring for Beta"""

    def __init__(self, arg):
        super(Beta, self).__init__()
        self.arg = arg

    def onJoin(self):
        print(PAASDF)


class Send(riffle.Domain):

    def onJoin(self):

        # NO NEW CONNECTION
        b = Beta().join()

        # Example Pub/Sub Basic - This is a basic pub/sub
        self.publish("basicSub", "Hello")
        # End Example Pub/Sub Basic

        # Example Pub/Sub Objects - This tests sending an object using pub/sub
        class Stuff(riffle.Model):
            name = "This guy"
        s = Stuff()
        self.publish("objectSub", s)
        # End Example Pub/Sub Objects

        # self.leave()


app = riffle.Domain("xs.demo.test")

if __name__ == '__main__':
    Send("example", superdomain=app).join()
    exit()

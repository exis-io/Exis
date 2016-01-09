
import riffle

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()


class Send(riffle.Domain):

    def onJoin(self):

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

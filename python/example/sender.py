
import riffle

riffle.SetFabricLocal()
riffle.SetLogLevelInfo()

class User(riffle.Model):
    name = "John Doe"
    email = ''

    def sayHello(self, other):
        print 'Im ' + self.name + ', how are you, ' + other + '?'

class Sender(riffle.Domain):

    def onJoin(self):
        print "Sender Joined"
        beta.publish("sub", self.name)

        result = beta.call("reg", 1, 2).wait()
        print 'Done with result:', result

        beta.publish("model", User())
        # result = beta.call("nada").wait()
        # print 'Done with result:', result

    def result(self, ret):
        print 'Call returned with result: ', ret

if __name__ == '__main__':
    app = riffle.Domain("xs.damouse")
    beta = riffle.Domain("beta", superdomain=app)
    Sender("alpha", superdomain=app).join()

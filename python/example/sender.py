
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

        beta.publish("1", "1")

        result = beta.call("2", 1, 2).wait(int)
        print '\n1: expecting 42:', result

        # try:
        #     result = beta.call("reg", 1, 2).wait(str)
        # except riffle.Error, e:
        #     print "Call.wait threw an exception:", e

        # Note: exact same call as above, but with a different .wait type
        # try: 
        #     result = beta.call("reg", 1, 2).wait(str)
        # except riffle.Error, e:
        #     print "Call.wait threw an exception:", e
        # beta.publish("model", User())

        beta.publish("none", 'some guy')

    def result(self, ret):
        print 'Call returned with result: ', ret

if __name__ == '__main__':
    app = riffle.Domain("xs.damouse")
    beta = riffle.Domain("beta", superdomain=app)
    Sender("alpha", superdomain=app).join()

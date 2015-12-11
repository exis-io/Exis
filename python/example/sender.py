
import riffle

class Sender(riffle.Domain):

    def onJoin(self):
        print "Sender Joined" 

Sender("xs.damouse.a").join()
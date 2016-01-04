
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class Recv(riffle.Domain):
    def onJoin(self):
        # Example Pub/Sub Basic - This is a basic version of a pub/sub
        @want(str)
        def basicSub(s):
            print s # Expects a string, like "Hello"
        self.subscribe("basicSub", basicSub)
        # End Example Pub/Sub Basic
        
        # Example Pub/Sub Objects - This sub expects an object
        class Stuff(riffle.Model):
            name = ""
        @want(Stuff)
        def objectSub(o):
            print "[objectSub] Got: {}".format(repr(o)) # Expects an object, like Stuff
        self.subscribe("objectSub", objectSub)
        # End Example Pub/Sub Objects
        
        # Example Pub/Sub OOO Racey - This shows that pubs can arrive out of order unless you call .wait() on them
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
    app = riffle.Domain("xs.demo.test")
    Recv("example", superdomain=app).join()
    exit()

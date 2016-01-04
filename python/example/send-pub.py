
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

        # Example Pub/Sub OOO Racey - This shows that pubs can arrive out of order unless you call .wait() on them
        for i in range(0, 20):
            self.publish("oooRaceSub", i)
        # End Example Pub/Sub OOO Racey
        
        # Example Pub/Sub OOO Corrected - This shows that pubs will arrive in order because we called wait()
        # TODO: these aren't in order yet b/c the core is highly parallelized, we need to look into this
        for i in range(0, 20):
            self.publish("oooCorrectSub", i).wait()
        # End Example Pub/Sub OOO Corrected

        # TODO: need to get leave working
        #self.leave()


app = riffle.Domain("xs.demo.test")

if __name__ == '__main__':
    Send("example", superdomain=app).join()
    exit()

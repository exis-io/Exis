
import riffle

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class Send(riffle.Domain):
    def onJoin(self):
        # Example Pub/Sub - This is a basic pub/sub
        beta.publish("sub", "Hi")
        # End Example Pub/Sub
        
        # Example Pub/Sub Basic - This is a basic pub/sub
        beta.publish("basicSub", "Hello")
        # End Example Pub/Sub Basic
        
        # Example Pub/Sub Objects - This tests sending an object using pub/sub
        class Stuff(riffle.Model):
            name = "This guy"
        s = Stuff()
        beta.publish("objectSub", s)
        # End Example Pub/Sub Objects

        # Example Pub/Sub OOO Racey - This shows that pubs can arrive out of order unless you call .wait() on them
        for i in range(0, 20):
            beta.publish("oooRaceSub", i)
        # End Example Pub/Sub OOO Racey
        
        # Example Pub/Sub OOO Corrected - This shows that pubs will arrive in order because we called wait()
        # TODO: these aren't in order yet b/c the core is highly parallelized, we need to look into this
        for i in range(0, 20):
            beta.publish("oooCorrectSub", i).wait()
        # End Example Pub/Sub OOO Corrected

        # TODO: need to get leave working
        #app.leave()
        #beta.leave()
        #self.leave()


app = riffle.Domain("xs.damouse")
beta = riffle.Domain("beta", superdomain=app)

if __name__ == '__main__':
    Send("alpha", superdomain=app).join()
    exit()








class Sender(riffle.Domain):

    def onJoin(self):
        print "Sender Joined"
        beta.publish("sub", self.name)

        result = want(str).beta.call("reg", 1, 2).wait()
        print 'Done with result:', result
        def fp(res):
            print(res)
        d = beta.call("reg", 1, 2)
        
        d.cb(fp)

    def result(self, ret):
        print 'Call returned with result: ', ret
        # beta.call("kill", None)

if __name__ == '__main__':
    app = riffle.Domain("xs.damouse")
    beta = riffle.Domain("beta", superdomain=app)
    Sender("alpha", superdomain=app).join()

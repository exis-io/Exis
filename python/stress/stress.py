import riffle

import time

#riffle.SetLogLevelDebug()
#riffle.SetFabricLocal()

# How to connect
def CreateDomains(url, suffix="", domain="xs.demo.stress"):
    riffle.SetFabric(url)
    s = riffle.Domain(domain)
    client = Stressor("client" + suffix, superdomain=s)
    backend = Stressor("backend" + suffix, superdomain=s)
    return client, backend


class Stressor(riffle.Domain):
    def addAction(self, d):
        actions = self.__dict__.get("actions", [])
        actions.append(d)
        self.actions = actions
    
    def start(self, backend=None):
        self.backend = backend
        self.join()
    
    def sub(self, d):
        def privSub(myep, ts, pyld):
            tsEnd = time.time()
            print "Pub/Sub  {}: {} - {} = {}".format(myep, ts, tsEnd, tsEnd - ts)
        for i in range(d.get('repeat', 1)):
            for j in range(d.get('num', 1)):
                self.subscribe("{}{}".format(d['ep'], i), privSub)
    
    def pub(self, d):
        for i in range(d.get('repeat', 1)):
            myep = "{}{}".format(d['ep'], i)
            for j in range(d.get('num', 1)):
                self.backend.publish(myep, myep, time.time(), d['pyld'])
    
    def reg(self, d):
        def privReg(myep, ts, pyld):
            return time.time()
        for i in range(d.get('repeat', 1)):
            self.register("{}{}".format(d['ep'], i), privReg)
    
    def call(self, d):
        for i in range(d.get('repeat', 1)):
            myep = "{}{}".format(d['ep'], i)
            for j in range(d.get('num', 1)):
                tsStart = time.time()
                tsMid = self.backend.call(myep, myep, tsStart, d['pyld']).wait()
                tsEnd = time.time()
                print "Reg/Call {}: {}, {}, {} = {} ({})".format(myep, tsStart, tsMid, tsEnd, tsEnd - tsStart, (tsMid - tsStart) / (tsEnd - tsStart))
        
    def onJoin(self):
        self.actionDict = {
            "subscribe": self.sub,
            "publish": self.pub,
            "call": self.call,
            "register": self.reg
        }
        print "{} Starting".format(self.name)

        for a in self.actions:
            action = a['action']
            
            self.actionDict[action](a)



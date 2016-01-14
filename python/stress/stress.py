import riffle
from riffle import want

import time

#riffle.SetLogLevelDebug()
#riffle.SetFabricLocal()

# How to connect
def CreateDomains(url):
    riffle.SetFabric(url)
    s = riffle.Domain("xs.demo.stress")
    client = Stressor("client", superdomain=s)
    backend = Stressor("backend", superdomain=s)
    return client, backend


class Stressor(riffle.Domain):
    def addAction(self, action, number, endpoint, payload=None):
        actions = self.__dict__.get("actions", [])
        actions.append(dict(action=action, number=number, endpoint=endpoint, payload=payload))
        self.actions = actions
    
    def start(self, backend=None):
        self.backend = backend
        self.join()
    
    def sub(self, num, ep, pyld):
        def privSub(myep, ts):
            tsEnd = time.time()
            print "{}: {} - {} = {}".format(myep, ts, tsEnd, tsEnd - ts)
        for i in range(num):
            self.subscribe("{}{}".format(ep, i), privSub)
    
    def pub(self, num, ep, pyld):
        for i in range(num):
            myep = "{}{}".format(ep, i)
            self.backend.publish(myep, myep, time.time())
        
    def onJoin(self):
        self.actionDict = {
            "subscribe": self.sub,
            "publish": self.pub
        }
        print "{} Starting".format(self.name)

        for a in self.actions:
            action, num, ep, pyld = a['action'], a['number'], a['endpoint'], a['payload']
            
            self.actionDict[action](num, ep, pyld)



#!/usr/bin/python2

"""
    main for stress
    Run this code to stress the system.
"""

import os
import stress

CLIENT = os.environ.get("CLIENT", None)
WS_URL = os.environ.get("WS_URL", "ws://localhost:8000/ws")
NUM = 100
REPEAT = 1
PYLD_SIZE = 1

if __name__ == "__main__":
    suffix = os.environ.get("SUFFIX", "")
    domain = os.environ.get("DOMAIN", "xs.demo.stress")
    c, b = stress.CreateDomains(WS_URL, suffix, domain)
    
    # MELT
    if os.environ.get("MELT", False):
        print "!!!!!!! WARNING: This is going to really f-up whatever node you point it at, be careful!!!!!!!!"
        if(CLIENT):
            for p in [1, 100, 1000]:
                for i in range(1, 10):
                    c.addAction(dict(action="publish", num=100*i, repeat=10*i, ep="melt-", pyld="EXIS"*p))
                    c.addAction(dict(action="call", num=100*i, repeat=10*i, ep="melt-", pyld="EXIS"*p))
        else:
            for i in range(1, 10):
                b.addAction(dict(action="subscribe", num=1+i, repeat=10*i, ep="melt" + i, pyld=None))
                b.addAction(dict(action="register", num=1, repeat=10*i, ep="melt" + i, pyld=None))
    
    # Simple pub/sub
    if os.environ.get("SIMPLE_PUBSUB", False):
        if(CLIENT):
            c.addAction(dict(action="publish", num=NUM, repeat=REPEAT, ep="simplePB-", pyld="EXIS"*PYLD_SIZE))
        else:
            b.addAction(dict(action="subscribe", num=NUM, repeat=REPEAT, ep="simplePB-", pyld=None))

    # Simple reg/call
    if os.environ.get("SIMPLE_REGCALL", False):
        if(CLIENT):
            c.addAction(dict(action="call", num=NUM, repeat=REPEAT, ep="simpleRC-", pyld="EXIS"*PYLD_SIZE))
        else:
            b.addAction(dict(action="register", num=NUM, repeat=REPEAT, ep="simpleRC-", pyld=None))

    # Combo pub/sub + reg/call
    if os.environ.get("PUBSUB_REGCALL", False):
        if(CLIENT):
            c.addAction(dict(action="publish", num=NUM, repeat=REPEAT, ep="simplePB-", pyld="EXIS"*PYLD_SIZE))
            c.addAction(dict(action="call", num=NUM, repeat=REPEAT, ep="simpleRC-", pyld="EXIS"*PYLD_SIZE))
        else:
            b.addAction(dict(action="register", num=NUM, repeat=REPEAT, ep="simpleRC-", pyld=None))
            b.addAction(dict(action="subscribe", num=NUM, repeat=REPEAT, ep="simplePB-", pyld=None))

    # Pub to lots of subs
    if os.environ.get("PUB_A_LOT", False):
        if(CLIENT):
            c.addAction(dict(action="publish", num=NUM, repeat=REPEAT, ep="simplePB-", pyld="EXIS"*PYLD_SIZE))
            c.addAction(dict(action="call", num=NUM, repeat=REPEAT, ep="simpleRC-", pyld="EXIS"*PYLD_SIZE))
        else:
            b.addAction(dict(action="register", num=NUM, repeat=REPEAT, ep="simpleRC-", pyld=None))
            b.addAction(dict(action="subscribe", num=NUM, repeat=REPEAT, ep="simplePB-", pyld=None))

    # Many connections vs just one with lots of things on it
    if os.environ.get("MANY_CONN_PUBSUB", False):
        if(CLIENT):
            c.addAction(dict(action="publish", num=NUM, repeat=1, ep="simplePB-", pyld="EXIS"*PYLD_SIZE))
        else:
            b.addAction(dict(action="subscribe", num=NUM, repeat=1, ep="simplePB-", pyld=None))
    
    # Many connections vs just one with lots of things on it
    if os.environ.get("MANY_CONN_REGCALL", False):
        if(CLIENT):
            c.addAction(dict(action="call", num=NUM, repeat=1, ep="simpleRC-", pyld="EXIS"*PYLD_SIZE))
        else:
            b.addAction(dict(action="register", num=NUM, repeat=1, ep="simpleRC-", pyld=None))

    # The effect on performance of one user getting rate limited but another works fine
    # TODO

    # Validating the rate limiting
    if os.environ.get("RATE_LIMIT", False):
        if(CLIENT):
            c.addAction(dict(action="publish", num=NUM, repeat=REPEAT, ep="simplePB-", pyld="EXIS"*PYLD_SIZE))
            c.addAction(dict(action="call", num=NUM, repeat=REPEAT, ep="simpleRC-", pyld="EXIS"*PYLD_SIZE))
        else:
            b.addAction(dict(action="register", num=NUM, repeat=REPEAT, ep="simpleRC-", pyld=None))
            b.addAction(dict(action="subscribe", num=NUM, repeat=REPEAT, ep="simplePB-", pyld=None))

    
    # Activate everything
    if(CLIENT):
        c.start(b)
    else:
        b.start(None)

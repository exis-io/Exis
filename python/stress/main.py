#!/usr/bin/python2

"""
    main for stress
    Run this code to stress the system.
"""

import os
import stress

CLIENT = os.environ.get("CLIENT", None)

if __name__ == "__main__":
    c, b = stress.CreateDomains("ws://localhost:8000/ws")

    NUM = 100

    if(CLIENT):
        c.addAction("publish", NUM, "test1-", "PAYLOAD")
        #c.addAction("publish", NUM, "test1-", "PAYLOAD")
        #c.addAction("publish", NUM, "test1-", "PAYLOAD")
        #c.addAction("publish", NUM, "test1-", "PAYLOAD")
    else:
        b.addAction("subscribe", NUM, "test1-")

    if(CLIENT):
        c.start(b)
    else:
        b.start(None)

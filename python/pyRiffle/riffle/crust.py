import ctypes
import os

# When runnin as a package
# _DIRNAME = os.path.dirname(__file__)
# go = ctypes.cdll.LoadLibrary(os.path.join(_DIRNAME, 'libriffmantle.so'))

# When running locally
core = ctypes.cdll.LoadLibrary('./libriffmantle.so')

from greenlet import greenlet

def test1():
    print 12
    gr2.switch()
    print 34

def test2():
    print 56
    gr1.switch()
    print 78

# if __name__ == '__main__':
#     gr1 = greenlet(test1)
#     gr2 = greenlet(test2)
#     gr1.switch()

def main():

    print "Starting"

    print core.Test()
    print core.Connector('ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws', 'xs.damouse')
    
    print "Stopped"

if __name__ == '__main__':
    main()
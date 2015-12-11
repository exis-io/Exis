from greenlet import greenlet
import ctypes
import os

# When runnin as a package
# _DIRNAME = os.path.dirname(__file__)
# go = ctypes.cdll.LoadLibrary(os.path.join(_DIRNAME, 'libriffmantle.so'))

# When running locally-- no gopy
# mantle = ctypes.cdll.LoadLibrary('./libriffmantle.so')

# When running with gopy
import riffle

riffle.SetLoggingLevel(3)


class App(object):

    def __init__(self):
        self._app = riffle.App()
        self._app.Init()

    def recv(self):
        print "Starting receive"

        while True:
            invocation = self._app.Receive()
            print "Received invocation: ", invocation

app = App()


class Domain(object):

    def __init__(self, name):
        self._domain = app._app.NewDomain(name)
        self.name = name

    def join(self):
        self._domain.Join()
        app.recv()


def main():
    print "Starting"

    d = Domain("xs.damouse")
    d.join()

    print "Stopped"

if __name__ == '__main__':
    main()


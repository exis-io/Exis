
"""
    runnode module

    Launches a local node for testing, restarting, etc..
"""

import sys
import os
import subprocess
import time
import signal
import colorama
from colorama import Fore, Back, Style

from threading import Thread, Event
from utils.utils import timestr

def f(args):
    pass
verbose = f
def enableVerbose():
    global verbose
    def f(args):
        print args
    verbose = f

colorama.init()

NODEPATH = None
NODE_SUFFIX = "src/github.com/exis-io/node"
GOPATH = os.environ.get("GOPATH", None)
if(GOPATH is None):
    print("!" * 50)
    print("!! $GOPATH not found, cannot launch node")
    print("!" * 50)
    exit()
else:
    if ":" in GOPATH:
        found = False
        for g in GOPATH.split(":"):
            np = "{}/{}".format(g, NODE_SUFFIX)
            if os.path.exists(np):
                found = True
                NODEPATH = np
                break
    else:
        np = "{}/{}".format(GOPATH, NODE_SUFFIX)
        if os.path.exists(np):
            NODEPATH = np

if NODEPATH is None:
    sys.stderr.write("!! Cannot find the node, should be at $GOPATH/{}\n".format(NODE_SUFFIX))

ON_POSIX = "posix" in sys.builtin_module_names

PERMS = os.environ.get("EXIS_PERMISSIONS", "off")
AUTH = os.environ.get("EXIS_AUTHENTICATION", "off")

class Node:
    """
    Class run launch and manage the node
    """
    def __init__(self):
        self.env = {
            "PATH": os.environ['PATH'],
            "GOBIN": os.environ['GOBIN'],
            "GOPATH": GOPATH,
            "EXIS_PERMISSIONS": PERMS,
            "EXIS_AUTHENTICATION": AUTH
        }
        self.cwd = "{}".format(NODEPATH)
        self.running = False
        self.proc = None
        self.stdout, self.stderr = list(), list()
        self.restartEvent = Event()
        self.restartOpts = dict()
    
    def kill(self):
        verbose(Fore.GREEN + "-- {} Killing the node".format(timestr()) + Style.RESET_ALL)
        self.running = False
        # Need to bring out the big guns to stop the proc, this is because it launches separate children
        # so we first set the process group to a unique value (using preexec_fn below), then we kill that
        # unique process group with the command here:
        try:
            os.killpg(os.getpgid(self.proc.pid), signal.SIGTERM)
        except:
            print Fore.YELLOW + "Unable to kill node" + Style.RESET_ALL
            print "Stderr: " + "\n".join(self.stderr)

    def restart(self, line):
        # See if we need to look for options
        self.restartOpts = dict()
        if "," in line:
            try:
                for kw in line.split(',')[1:]:
                    k, w = kw.split(':')
                    self.restartOpts[k] = float(w)
            except:
                self.restartOpts = dict()
                print Fore.YELLOW + "Bad args to NODERESTART command found, looking for <FLAG>,in:#,wait:#" + Style.RESET_ALL

        verbose(Fore.GREEN + "-- {} Performing restart".format(timestr()) + Style.RESET_ALL)
        
        self.restartEvent.set()

    def _watchRestart(self):
        while(True):
            self.restartEvent.wait()
            optIn = self.restartOpts.get('in', None)
            optWait = self.restartOpts.get('wait', None)
            if optIn:
                time.sleep(optIn)
            self.kill()
            if optWait:
                time.sleep(optWait)
            self.start()
            self.restartEvent.clear()

    def setup(self):
        self.watchThd = Thread(target=self._watchRestart)
        self.watchThd.daemon = True
        self.watchThd.start()
        # Build the main script, it performs better than doing "go run" (especially if you need to restart it)
        if not os.path.exists("{}/main".format(self.cwd)):
            proc = subprocess.Popen(["go", "build", "runner/main.go"], cwd=self.cwd,
                                         stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output, errors = proc.communicate()
            
            if proc.returncode:
                print Fore.RED + "!! Unable to build node" + Style.RESET_ALL
                raise Exception("Unable to build node: {}".format(errors))
    
    def start(self):
        self.running = True

        verbose(Fore.GREEN + "-- {} Starting the node".format(timestr()) + Style.RESET_ALL)
        self.proc = subprocess.Popen(["./main"], cwd=self.cwd, env=self.env,
                                     stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1,
                                     close_fds=ON_POSIX, preexec_fn=os.setsid)

        self.readOut = Thread(target=self._read, args=(self.proc.stdout, self.stdout))
        self.readOut.daemon = True

        self.readErr = Thread(target=self._read, args=(self.proc.stderr, self.stderr))
        self.readErr.daemon = True

        self.readOut.start()
        self.readErr.start()
    
    def _read(self, out, stor):
        """
        Threaded function that spins and reads the output from the executing process.
        """
        while(self.running):
            for line in iter(out.readline, b''):
                l = line.rstrip()
                stor.append((time.time(), l))
        out.close()

if __name__ == "__main__":
    n = Node()
    n.start()
    time.sleep(10)
    n.restart()
    time.sleep(10)
    n.kill()

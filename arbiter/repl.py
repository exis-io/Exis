
"""
    repl module

    Uses the coreappliances repler to execute code but in a local manner.
"""

import sys, os, tempfile, shutil, subprocess, time, signal
from threading import Thread

# Make sure we know where the core appliances are
APPLS = os.environ.get("EXIS_APPLIANCES", None)
if(APPLS is None):
    print("!! Need the $EXIS_APPLIANCES variable set to proceed")
    exit()

ON_POSIX = "posix" in sys.builtin_module_names

from utils import utils

WS_URL = os.environ.get("WS_URL", "ws://localhost:8000/ws")
DOMAIN = os.environ.get("DOMAIN", "xs.demo.test")
BASEPATH = "{}/repler".format(APPLS)

def _expectPython(line, eType, eVal):
    """
    Internal function that takes the expect line of code and restructures it into something
    that can be called to be functionally tested to return the right value and type.
    Returns the replacement code
    """
    return line.replace('print(', 'assert({} == '.format(eVal))

def _expectSwift(line, et, ev):
    pass

_expect = {
    "py": _expectPython,
    "swift": _expectSwift
}

def _terminatePython(code):
    """
    Adds a leave line, we need to see the code to see how to make the indent look...
    """

def _terminateSwift(code):
    pass

_terminate = {
    "py": _terminatePython,
    "swift": _terminateSwift
}


class Coder:
    """
    Super class that contains the methods needed for each language to deal with lang
    specific code and functions.
    """
    def __init__(self, task, action):
        self.task = task
        self.action = action

    def setupTerminate(self, code):
        print "!! Not implemented"

    def expect2assert(self):
        print "!! Not implemented"

    def checkExecution(self, output):
        print "!! Not implemented"

class PythonCoder(Coder):
    def setupTerminate(self, code):
        """
        Assume the last line of the code is enough info to judge indenting
        Also assume they didn't use TABS!!!!!
        """
        if self.task.action in ("publish", "call"):
            c = self.task.code[-1]
            code.append("{}exit()".format(" " * (len(c)-len(c.lstrip(' ')))))
    
    def expect2assert(self):
        if self.task.expectLine >= 0:
            expectLine = self.task.code[self.task.expectLine]
            return expectLine.replace('print(', 'assert({} == '.format(self.task.expectVal))
        else:
            return None

    def getExpect(self):
        """
        Returns a properly formatted lang-specific value that we should be searching for.
        """
        if self.task.expectType == "string":
            return self.task.expectVal.strip("'\"")
        else:
            return self.task.expectVal
    
    def checkExecution(self, out, err):
        """
        Take the stderr and stdout arrays and check if execute was ok or not.
        Also check the output for any expect data.
        Returns:
            String matching the output that led to the successful result,
            or None if a failure or no match
        """
        #print(out, err)
        ev = self.getExpect()
        
        good = None
        # Sometimes we shouldn't expect anything and thats ok
        if ev is None and len(out) == 0:
            good = "no expect required"
        
        for o in out:
            if ev in o:
                good = ev

        if err:
            # Look at the error to see whats up
            errOk = False
            for e in err:
                # This needs to be fixed, its a gocore->python specific error that will go away!
                if "_shutdown" in e:
                    errOk = True
                    break
            if not errOk:
                print "!! Found error:"
                print "\n".join(err)
                return False
        return good


coders = {
    "py": PythonCoder
}
def getCoder(task, action):
    """Returns an instance of the proper class or None"""
    c = coders.get(task.lang, None)
    return c(task, action) if c else None

class ReplIt:
    """
    This class holds onto all the components required to take a task and execute it.
    """
    def __init__(self, taskSet, action):
        self.action = action
        self.task = taskSet.getTask(action)
        if self.task is None:
            raise Exception("No Task found")
        self.lang = taskSet.getFullLang()
        self.proc = None
        self.stdout = list()
        self.stderr = list()
        self.readThd = None
        self.executing = False
        self.coder = None

        self._setup()

    def _setup(self):
        """
        Sets up a temp directory for this task and copies the proper code over (like a fake docker)
        """
        # Get the coder for this lang
        self.coder = getCoder(self.task, self.action)
        if not self.coder:
            raise Exception("Couldn't find the Coder for this lang")
        
        # Where is the repl code we need?
        self.basepath = "{}/repl-{}/".format(BASEPATH, self.lang)

        # Setup a temp dir for this test
        self.testDir = tempfile.mkdtemp(prefix="arbiterTask")
        
        # Copy over everything into this new dir
        src = os.listdir(self.basepath)
        for f in src:
            ff = os.path.join(self.basepath, f)
            if(os.path.isfile(ff)):
                shutil.copy(ff, self.testDir)

        # Setup env vars
        self.env = {
            "WS_URL": WS_URL,
            "DOMAIN": DOMAIN
        }

        # Language specific things
        self.env["PYTHONPATH"] = self.testDir
        
        # Get the code pulled and formatted
        self.execCode = self.getTestingCode()
        self.env["EXIS_REPL_CODE"] = self.execCode

    
    def _read(self, out, stor):
        """
        Threaded function that spins and reads the output from the executing process.
        """
        while(self.executing):
            for line in iter(out.readline, b''):
                stor.append(line)
        out.close()
    
    def kill(self):
        """
        Kills the process and stops reading in the data from stdout.
        Returns:
            True if all ok, False otherwise
        """
        #print "KILL {} : {} @ {} PID {}".format(self.action, self.task.fullName(), self.testDir, self.proc.pid)
        self.executing = False
        # Need to bring out the big guns to stop the proc, this is because it launches separate children
        # so we first set the process group to a unique value (using preexec_fn below), then we kill that
        # unique process group with the command here:
        os.killpg(os.getpgid(self.proc.pid), signal.SIGTERM)
        #self.proc.kill()
        #self.proc.wait()
        
        res = self.coder.checkExecution(self.stdout, self.stderr)
        if res is not None:
            print "{} {} : SUCCESS (Found {})".format(self.action, self.task.fullName(), res)
            return True
        else:
            print "{} {} : FAILURE".format(self.action, self.task.fullName())
            print "Received: {}".format("\n".join(self.stdout))
            print "Files located at: {}".format(self.testDir)
            print "Code Executed:"
            print self.execCode
            return False
            
    
    def cleanup(self):
        """
        Removes the temp dirs used for this test.
        """
        shutil.rmtree(self.testDir)
    
    def execute(self):
        """
        Launches the actual function. To do this properly we need to launch a reader
        thread for the stdout since this will result in a blocking call otherwise.
        """
        self.executing = True
        print "EXEC {} : {} @ {}".format(self.action, self.task.fullName(), self.testDir)
        
        self.proc = subprocess.Popen(["./run2.sh"], cwd=self.testDir, env=self.env,
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1,
                        close_fds=ON_POSIX, preexec_fn=os.setsid)

        self.readOut = Thread(target=self._read, args=(self.proc.stdout, self.stdout))
        self.readOut.daemon = True
        self.readOut.start()
        
        self.readErr = Thread(target=self._read, args=(self.proc.stderr, self.stderr))
        self.readErr.daemon = True
        self.readErr.start()

    def getAssertedCode(self):
        """
        Returns the assert added code so that this code segment will not complete properly if
        the return type is not correct (because we replace the "print" with an "assert").
        """
        # If there is an expect then replace it with an assert for testing
        if self.task.expectLine >= 0:
            expectLine = self.task.code[self.task.expectLine]
            replacement = _expect[self.task.lang](expectLine, self.task.expectType, self.task.expectVal)
            code = [a for a in self.task.code]
            # Insert the assert before the print, so that we can search for our results and know
            # if they came or not in the stdout (an assert would cause them not to come)
            code.insert(self.task.expectLine, replacement)
        else:
            code = [a for a in self.task.code]

    def getTestingCode(self):
        """
        This function returns the properly formatted code needed to make the repl calls work.
        This means two things: 1) On call/pub examples it adds the proper leave() at the end
        and 2) it replaces the # Expect code with the proper assert.
        """
        code = [a for a in self.task.code]
        self.coder.setupTerminate(code)
        
        return "\n".join(code)

def executeAll(taskList, actionList):
    procs = list()
    for ts, a in zip(taskList, actionList):
        r = ReplIt(ts, a)
        r.execute()

        procs.append(r)
    
    time.sleep(5)
    # Go back through and terminate in reverse order
    ok = True
    for p in procs[::-1]:
        ok &= p.kill()

    # If everything was ok then cleanup the temp dirs
    if ok:
        for p in procs:
            p.cleanup()
    




"""
    repl module

    Uses the coreappliances repler to execute code but in a local manner.
"""

import sys, os, tempfile, shutil, subprocess, time, signal
from threading import Thread, Event

# Make sure we know where the core appliances are
APPLS = os.environ.get("EXIS_APPLIANCES", None)
if(APPLS is None):
    print("!! Need the $EXIS_APPLIANCES variable set to proceed")
    exit(1)

ON_POSIX = "posix" in sys.builtin_module_names

from utils import utils

WS_URL = os.environ.get("WS_URL", "ws://localhost:8000/ws")
DOMAIN = os.environ.get("DOMAIN", "xs.demo.test")
BASEPATH = "{}/repler".format(APPLS)

if not os.path.exists("{}/repl-python/run2.sh".format(BASEPATH)) or not os.path.exists("{}/repl-swift/run2.sh".format(BASEPATH)):
    print "Please checkout proper version of core appliances."
    print "You must have the {core}/repler/repl-{lang}/run2.sh commands for arbiter to work!"
    exit(1)

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
                pass
            if not errOk:
                print "!! Found error:"
                print "\n".join(err)
                return None
        return good

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
                return None
        return good

class SwiftCoder(Coder):
    def setupTerminate(self, code):
        # TODO
        pass
    
    def expect2assert(self):
        # TODO
        return None

    def getExpect(self):
        """
        Returns a properly formatted lang-specific value that we should be searching for.
        """
        return self.task.expectVal
    


coders = {
    "py": PythonCoder,
    "swift": SwiftCoder
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
        self.buildComplete = Event()

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
            elif(os.path.isdir(ff)):
                shutil.copytree(ff, "{}/{}".format(self.testDir, f))

        # Setup env vars
        self.env = {
            "WS_URL": WS_URL,
            "DOMAIN": DOMAIN,
            "PATH": os.environ["PATH"]
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
                if line.rstrip() == "___BUILDCOMPLETE___":
                    self.buildComplete.set()
                else:
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
        This returns a threading.Event() which should be waited() on before starting the next
        ReplIt.execute function since there are race conditions between building of different langs.
        """
        self.executing = True
        print "EXEC {} : {} @ {}".format(self.action, self.task.fullName(), self.testDir)
        
        self.proc = subprocess.Popen(["./run2.sh"], cwd=self.testDir, env=self.env,
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1,
                        close_fds=ON_POSIX, preexec_fn=os.setsid)

        self.readOut = Thread(target=self._read, args=(self.proc.stdout, self.stdout))
        self.readOut.daemon = True
        
        self.readErr = Thread(target=self._read, args=(self.proc.stderr, self.stderr))
        self.readErr.daemon = True
        
        self.readOut.start()
        self.readErr.start()

    def getAssertedCode(self):
        """
        Returns the assert added code so that this code segment will not complete properly if
        the return type is not correct (because we replace the "print" with an "assert").
        """
        # TODO

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
        a = r.buildComplete.wait(5)
        if a is False:
            print "!! {} never completed setup process (BUILDCOMPLETE never found)".format(ts)

        procs.append(r)
    
    # Now let the system do its thing
    time.sleep(5)

    # Go back through and terminate in reverse order
    ok = True
    for p in procs[::-1]:
        ok &= p.kill()

    # If everything was ok then cleanup the temp dirs
    if ok:
        for p in procs:
            p.cleanup()
    



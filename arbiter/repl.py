
"""
    repl module

    Uses the coreappliances repler to execute code but in a local manner.
"""

import sys
import os
import tempfile
import shutil
import subprocess
import time
import signal
import glob
import colorama
import atexit
from random import randint

from colorama import Fore, Back, Style

from threading import Thread, Event
import runnode


def f(args):
    pass
verbose = f


def enableVerbose():
    runnode.enableVerbose()
    global verbose

    def f(args):
        print args
    verbose = f

colorama.init()

# Allow fake versions of the repl functions for quick testing
STUB_REPL = False

# This is the time that we will wait for a process to complete (using the ___*COMPLETE___ tags)
WAIT_TIME = 15

# Browser testing support???
try:
    import selenium
    BROWSER_TESTS = True
except:
    BROWSER_TESTS = False
    print "!! Unable to find selenium, run pip install selenium to perform browser testing"

# atexit functionality to clean up our mess
pidKillList = []


def onexit():
    for pid in pidKillList:
        try:
            print "On exit, killing {}".format(pid)
            os.killpg(os.getpgid(pid), signal.SIGTERM)
        except:
            print Fore.RED + "Unable to kill {}".format(pid) + Style.RESET_ALL
    # Also kill the node
    killNode()
atexit.register(onexit)

# Handle node launching stuff here
node = None


def launchNode():
    global node
    node = runnode.Node()
    node.setup()
    node.start()


def killNode():
    if node:
        node.kill()

DEBUG = False


def debugMode():
    global DEBUG
    DEBUG = True

EXISREPO = os.environ.get("EXIS_REPO", None)
if(EXISREPO is None):
    print("!" * 50)
    print("!! $EXIS_REPO not found, REPL may not work")
    print("!" * 50)

ON_POSIX = "posix" in sys.builtin_module_names

WS_URL = os.environ.get("WS_URL", "ws://localhost:8000/ws")
DOMAIN = os.environ.get("DOMAIN", "xs.demo.test")
TEST_PREFIX = "arbiterTask"


class Coder:

    """
    Super class that contains the methods needed for each language to deal with lang
    specific code and functions.
    """

    def __init__(self, task, action):
        self.task = task
        self.action = action
        self.tmpdir = None

    def copyFromBasePath(self, testDir):
        """Copy over everything into this new dir"""
        bp = self.getBasePath()
        src = os.listdir(bp + "/")
        for f in src:
            ff = os.path.join(bp + "/", f)
            if(os.path.isfile(ff)):
                shutil.copy(ff, testDir)
            elif(os.path.isdir(ff)):
                shutil.copytree(ff, "{}/{}".format(testDir, f))

    def setup(self, tmpdir):
        self.tmpdir = tmpdir
        # self.copyFromBasePath(tmpdir)
        shutil.copy("{}/arbiter/repler/{}".format(EXISREPO, self.getRunScript()), tmpdir)
        self._setup(tmpdir)

    def setupRunComplete(self, code):
        pass

    def setupEnv(self, env):
        pass

    def expect2assert(self):
        print "!! Not implemented"

    def getBasePath(self):
        return "{}/arbiter/repler/".format(EXISREPO)

    def getRunScript(self):
        # Find the run script, use run2 if it exists
        if STUB_REPL:
            return "{}-stub.sh".format(self.task.getLangName())
        else:
            return "{}-run.sh".format(self.task.getLangName())

    def getTestingCode(self):
        """
        This function returns the properly formatted code needed to make the repl calls work.
        This means two things: 1) On call/pub examples it adds the proper leave() at the end
        and 2) it replaces the # Expect code with the proper assert.
        """
        code = [a for a in self.task.code]
        if self.action in ("call", "publish"):
            self.setupRunComplete(code)

        return "\n".join(code)

    def checkStdout(self, out):
        ev = self.getExpect()

        good = None
        # Sometimes we shouldn't expect anything and thats ok
        if ev is None:
            good = "no expect required"
        else:
            for t, o in out:
                if ev in o:
                    good = ev
        return good

    def checkStderr(self, err):
        if err:
            return True
        return False

    def checkExecution(self, out, err):
        """
        Take the stderr and stdout arrays and check if execute was ok or not.
        Also check the output for any expect data.
        Returns:
            String matching the output that led to the successful result,
            or None if a failure or no match
        """
        res = self.checkStdout(out)
        e = self.checkStderr(err)
        if e == True:
            return None

        return res


class PythonCoder(Coder):

    def _setup(self, tmpdir):
        """
        We shouldn't have to do anything here, assume they have run 'sudo pip install -e .' in pyRiffle.
        """
        pass

    def setupRunComplete(self, code):
        pass  # code.append('{}print "___RUNCOMPLETE___"'.format(" " * self.getWhitespace(code[-1])))

    def getWhitespace(self, line):
        return len(line) - len(line.lstrip(' '))

    def setupEnv(self, env):
        env["PYTHONPATH"] = self.tmpdir
        if DEBUG:
            env["EXIS_SETUP"] = "riffle.SetLogLevelDebug()"

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
        if self.task.expectType == "str":
            return self.task.expectVal.strip("'\"")
        else:
            return self.task.expectVal

    def checkStderr(self, err):
        if err:
            # Look at the error to see whats up
            errOk = False
            for t, e in err:
                # This needs to be fixed, its a gocore->python specific error that will go away!
                if "_shutdown" in e:
                    errOk = True
                    break
            if not errOk:
                return True
        return False


class SwiftCoder(Coder):

    def _setup(self, tmpdir):
        """
        Need to copy over the proper files for swift build command (mantle/swiftRiffle).
        """
        # Copy Package from example
        swift = "{}/swift".format(EXISREPO)
        os.mkdir("{}/main".format(tmpdir))
        shutil.copy("{}/example/Package.swift".format(swift), "{}/main".format(tmpdir))
        shutil.copytree("{}/mantle".format(swift), "{}/mantle".format(tmpdir))
        shutil.copytree("{}/swiftRiffle".format(swift), "{}/swiftRiffle".format(tmpdir), symlinks=True)

    def setupRunComplete(self, code):
        pass  # code.append('print("___RUNCOMPLETE___")')

    def setupEnv(self, env):
        if DEBUG:
            env["EXIS_SETUP"] = "Riffle.setLogLevelDebug()"

    def expect2assert(self):
        # TODO
        return None

    def getExpect(self):
        """
        Returns a properly formatted lang-specific value that we should be searching for.
        """
        if self.task.expectType == "String":
            return self.task.expectVal.strip("'\"")
        else:
            return self.task.expectVal


class NodeJSCoder(Coder):

    def _setup(self, tmpdir):
        """
        Need to run 'npm install BASEPATH/js/jsRiffle' in the tmp dir.
        """
        # proc = subprocess.Popen(["npm", "install", "{}/js/jsRiffle/".format(EXISREPO)], cwd=tmpdir,
        proc = subprocess.Popen(["npm", "link", "jsriffle"], cwd=tmpdir,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, errors = proc.communicate()

        if proc.returncode:
            print "!! We expect that you have run 'sudo npm link' in the jsRiffle dir"
            raise Exception("Unable to setup for JS: {}".format(errors))

    def setupRunComplete(self, code):
        pass  # code.append('setTimeout(function() { console.log("___RUNCOMPLETE___"); }, 3000);')

    def setupEnv(self, env):
        if DEBUG:
            env["EXIS_SETUP"] = "riffle.setLogLevelDebug();"

    def expect2assert(self):
        # TODO
        return None

    def getExpect(self):
        """
        Returns a properly formatted lang-specific value that we should be searching for.
        """
        if self.task.expectType == "String":
            return self.task.expectVal.strip("'\"")
        else:
            return self.task.expectVal


class BrowserCoder(Coder):

    def getBasePath(self):
        return "{}/arbiter/repler/".format(EXISREPO)

    def setupEnv(self, env):
        env["PYTHONPATH"] = self.tmpdir
        env["REPL_BROWSER_EXPECT"] = self.getExpect()
        # NOTE need to specify the DISPLAY for FireFox to open up in otherwise shit hits the fan
        env["DISPLAY"] = os.environ['DISPLAY']

    def setup(self, tmpdir):
        """
        OVERWRITES the Coder class setup file!
        Find jsRiffle and setup the browser html
        """
        self.tmpdir = tmpdir
        shutil.copy("{}/arbiter/repler/browser-run.sh".format(EXISREPO), tmpdir)
        shutil.copy("{}/arbiter/repler/browser-generate.sh".format(EXISREPO), tmpdir)
        try:
            shutil.copy("{}/js/jsRiffle/release/jsRiffle.js".format(EXISREPO), tmpdir)
        except:
            # If we are stubbing then don't care about missing libs here
            if not STUB_REPL:
                print Fore.RED + "Unable to find proper libraries for browser (did you compile js and browserify it?)" + Style.RESET_ALL
                raise Exception("Missing JS libs")

    def expect2assert(self):
        # TODO
        return None

    def getExpect(self):
        """
        Returns a properly formatted lang-specific value that we should be searching for.
        """
        if self.task.expectType == "String":
            return self.task.expectVal.strip("'\"")
        else:
            return self.task.expectVal

    def checkStdout(self, out):
        ev = self.getExpect()

        good = None
        # Sometimes we shouldn't expect anything and thats ok
        if ev is None:
            good = "no expect required"
        else:
            for t, o in out:
                if "___RUNCOMPLETE___" in o:
                    good = ev
        return good


coders = {
    "python": PythonCoder,
    "swift": SwiftCoder,
    "nodejs": NodeJSCoder,
    "browser": BrowserCoder
}


def getCoder(task, action):
    """Returns an instance of the proper class or None"""
    lang = task.getLangName()
    if lang == "browser" and BROWSER_TESTS == False:
        print "!! Warning cannot run browser tests without selenium, reverting to nodejs instead"
        c = coders.get("nodejs", None)
    else:
        c = coders.get(lang, None)
    return c(task, action) if c else None


class ReplIt:

    """
    This class holds onto all the components required to take a task and execute it.
    """

    def __init__(self, task, action):
        self.action = action
        self.task = task
        if self.task is None:
            raise Exception("No Task found")
        self.lang = task.getLangName()
        self.proc = None
        self.testDir = None
        self.stdout = list()
        self.stderr = list()
        self.readThd = None
        self.executing = False
        self.coder = None
        self.buildComplete = Event()
        self.setupComplete = Event()
        self.msgs = ""
        if action in ("call", "publish"):
            self.runComplete = Event()
        else:
            self.runComplete = None
        self.runScript = None

        self.success = None

    def setup(self, domainBase):
        """
        Sets up a temp directory for this task and copies the proper code over (like a fake docker)
        """
        # Get the coder for this lang
        self.coder = getCoder(self.task, self.action)
        if not self.coder:
            raise Exception("Couldn't find the Coder for this lang")

        # Where is the repl code we need?
        self.runScript = self.coder.getRunScript()

        # Setup a temp dir for this test
        self.testDir = tempfile.mkdtemp(prefix=TEST_PREFIX)

        # Now that the dir is setup, allow the coder to setup anything it needs for the lang
        self.coder.setup(self.testDir)

        # Get the code pulled and formatted
        self.execCode = self.coder.getTestingCode()

        # Setup env vars
        self.env = {
            "WS_URL": WS_URL,
            "DOMAIN": DOMAIN + domainBase,
            "PATH": os.environ["PATH"],
            "EXIS_REPL_CODE": self.execCode
        }

        self.coder.setupEnv(self.env)

    def _read(self, out, stor, expect):
        """
        Threaded function that spins and reads the output from the executing process.
        """
        while(self.executing):
            for line in iter(out.readline, b''):
                l = line.rstrip()
                if "___BUILDCOMPLETE___" in l:
                    if DEBUG:
                        stor.append((time.time(), l))
                    self.buildComplete.set()
                elif "___SETUPCOMPLETE___" in l:
                    if DEBUG:
                        stor.append((time.time(), l))
                    self.setupComplete.set()
                elif "___RUNCOMPLETE___" in l and self.runComplete:
                    stor.append((time.time(), l))
                    self.runComplete.set()
                elif "___NODERESTART___" in l:
                    if node != None:
                        if DEBUG:
                            stor.append((time.time(), l))
                        node.restart(l)
                    else:
                        self.msgs += "-- Node restart found but not running a node\n"
                else:
                    if expect is not None and expect in l:
                        # print Fore.GREEN + "Found Expect value" + Style.RESET_ALL
                        if self.runComplete:
                            self.runComplete.set()
                    stor.append((time.time(), l))
        out.close()

    def kill(self):
        """
        Kills the process and stops reading in the data from stdout.
        Returns:
            True if all ok, False otherwise
        """
        # print "KILL {} : {} @ {} PID {}".format(self.action, self.task.fullName(), self.testDir, self.proc.pid)
        self.executing = False
        # Need to bring out the big guns to stop the proc, this is because it launches separate children
        # so we first set the process group to a unique value (using preexec_fn below), then we kill that
        # unique process group with the command here:
        try:
            os.killpg(os.getpgid(self.proc.pid), signal.SIGTERM)
            pidKillList.remove(self.proc.pid)
        except:
            print Fore.RED + "Unable to kill process {}".format(self.task.fullName()) + Style.RESET_ALL

        res = self.coder.checkExecution(self.stdout, self.stderr)
        if res is not None:
            # print "{} {} : SUCCESS (Found {})".format(self.action, self.task.fullName(), res)
            self.success = True
            return True
        else:
            self.success = False
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

        verbose("EXEC {} : {} @ {}".format(self.action, self.task.fullName(), self.testDir))

        self.proc = subprocess.Popen(["./{}".format(self.runScript)], shell=True, cwd=self.testDir, env=self.env,
                                     stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1,
                                     close_fds=ON_POSIX, preexec_fn=os.setsid)
        pidKillList.append(self.proc.pid)

        ev = self.coder.getExpect()
        self.readOut = Thread(target=self._read, args=(self.proc.stdout, self.stdout, ev))
        self.readOut.daemon = True

        self.readErr = Thread(target=self._read, args=(self.proc.stderr, self.stderr, None))
        self.readErr.daemon = True

        self.readOut.start()
        self.readErr.start()


def executeTasks(taskList, actionList):
    """
    Given a list of tasks and an action it will zip them together and then execute them properly.
    Returns:
        True if the tests worked
        False if something went wrong
    """
    procs = list()

    # generates a random base domain for this test so all tasks can be parallized
    randomBaseDomain = str(randint(0, 99999))

    for t, a in zip(taskList, actionList):
        r = ReplIt(t, a)
        r.setup(randomBaseDomain)
        r.execute()
        a = r.buildComplete.wait(WAIT_TIME)
        if a is False:
            r.msgs += Fore.YELLOW + "!! {} never completed setup process (BUILDCOMPLETE never found)".format(t.fullName()) + Style.RESET_ALL

        a = r.setupComplete.wait(WAIT_TIME)
        if a is False:
            r.msgs += Fore.YELLOW + "!! {} never completed setup process (SETUPCOMPLETE never found)".format(t.fullName()) + Style.RESET_ALL

        procs.append(r)

    # Trying to speed up things, if the proc has a setupComplete flag then wait on it, it should
    # catch rather than sleeping for a crazy long time
    for p in procs:
        if p.runComplete:
            a = p.runComplete.wait(WAIT_TIME)
            if a is False:
                r.msgs += Fore.YELLOW + "!! {} never found setup complete, timeout hit".format(p.task.fullName()) + Style.RESET_ALL
                break
            else:
                # Not super happy about this but we still have a race condition where we need to wait before just
                # killing everything so any messages can get through quick, hopefully 0.5 sec is enough for now... :(
                time.sleep(0.5)

    # Go back through and terminate in reverse order
    ok = True
    for p in procs[::-1]:
        ok &= p.kill()

    printResult(procs)

    # If everything was ok then cleanup the temp dirs
    if ok:
        for p in procs:
            p.cleanup()
        return True
    else:
        return False


def executeTaskSet(taskSet):
    """
    Given one specific TaskSet it will execute the corresponding components of that (pub/sub or reg/call).
    Returns:
        None if nothing happened
        True if it worked
        False if it didn't
    """
    taskList, actionList = list(), list()
    # Pull the proper actions from the task

    lst = taskSet.getOrderedTasks()
    if len(lst) != 2:
        return None

    print "# {:3d} - {}\t".format(taskSet.index, taskSet.getName()),

    return executeTasks(lst, [l.action for l in lst])


def cleanupTests():
    # NOTE: This only works on linux flavored systems right now
    dirs = glob.glob("/tmp/{}*".format(TEST_PREFIX))
    for d in dirs:
        print d
        shutil.rmtree(d)


def printSetup(taskSet):
    ''' Pretty print for the setup of a test '''


def printResult(procs):
    ''' Pretty print the results of test

    TODO: make a verbose mode to output the old output

    '''

    print " ".rjust(10) + "",

    for t in procs:
        if t.success:
            print Fore.GREEN + t.action + " ",
        else:
            print Fore.RED + t.action + Style.RESET_ALL,

    for t in procs:
        if not t.success or verbose != f:
            printOutput = ""
            if len(t.stdout) > 2:
                printOutput = "\n".join([a[1] for a in t.stdout])
            else:
                printOutput = str([a[1] for a in t.stdout])
            print "\n\t" + Fore.YELLOW + t.action + ' expected: ' + Fore.WHITE \
                + str(t.coder.getExpect()) + Fore.YELLOW + ", output: " + Fore.WHITE \
                + printOutput,
            print "\n\t" + Fore.YELLOW + "file: " + t.task.fileName.split('/')[-1] \
                + " lines {}-{}".format(t.task.lineStart, t.task.lineEnd),
            print "\n\t" + "test dir: " + t.testDir

            if t.msgs:
                print "\tMessages: "
                print "\t\t" + t.msgs.replace("\n", "\n\t\t")

            print Fore.RED + "\n".join([a[1] for a in t.stderr]) + Style.RESET_ALL
            print Fore.CYAN + t.execCode + Style.RESET_ALL

    print Style.RESET_ALL

    if DEBUG:
        log = list()
        if node:
            log.extend([(t[0], t[1], "node", "out") for t in node.stdout])
            log.extend([(t[0], t[1], "node", "err") for t in node.stderr])

        for p in procs:
            log.extend([(t[0], t[1], p.task.action, "out") for t in p.stdout])
            log.extend([(t[0], t[1], p.task.action, "err") for t in p.stderr])
        log = sorted(log, key=lambda x: x[0])
        for l in log:
            print "{:.7f} {} {:>11s} : {}".format(l[0], l[3], l[2], l[1])

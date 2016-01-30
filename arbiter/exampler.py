"""
    The classes that help organize all examples for all languages. They are organized
    into one Examples class which holds many ExampleFiles and each ExampleFiles class
    can hold many Task objects which represents the actual code to execute.
"""

import glob, re, os

from collections import defaultdict as ddict

# They provide "python" but we need to know the extension is "py"
LANGS = {"python": "py", "swift": "swift", "nodejs": "js", "browser": "js", "go": "go"}
# We found a file with extension "py" and need to know its "python"
LANGS_EXT = {"py": "python", "swift": "swift", "js": "js", "go": "go", "browser": "js", "nodejs": "js"}

# Match to the start of an example, pull out the name of the example, and the docs for it
EX_START_RE = re.compile("^.*Example (.*)? - (.*)$")
# Match to the end of an example, and pull out the name of the example
EX_END_RE = re.compile("^.*End Example (.*)$")
# Trying to match specifically on calls to the 4 primary function calls, with an optional space
# between the function name and (. Also dealing with lower/upper case, and trying to look for 
# functional calls specifically so we ignore comments and stuff like that
EXIS_CMDS_RE = re.compile(".*([Rr]egister *\(|[Cc]all *\(|[Ss]ubscribe *\(|[Pp]ublish *\().*$")
# If they pass a command then use it
OPT_ACTION_RE = re.compile("^.*ARBITER set action (.*)$")

# Valid comments for each language
LANG_COMMENT_CHAR = {"py": "#", "swift": "//", "js": "//", "go": "//"}

def _parseStartMatch(m):
    tmpName = m.group(1)
    doc = m.group(2)
    # Deal with optional name thing
    opts = None
    tmpName = tmpName.split(" ")
    name = tmpName[0]
    if(len(tmpName) > 1):
        opts = " ".join(tmpName[1:])
    return name, opts, doc

def _getExpectRe(lang):
    comment = LANG_COMMENT_CHAR[lang]
    return re.compile("^.*{}+ Expects a[n]* (.*), like (.*)$".format(comment))

def _parseEndMatch(m):
    tmpName = m.group(1)
    # Deal with optional name thing
    opts = None
    tmpName = tmpName.split(" ")
    name = tmpName[0]
    if(len(tmpName) > 1):
        opts = " ".join(tmpName[1:])
    return name, opts


class Examples:
    """
    Holds onto all examples we have found, each example is an Example class
    representing a discrete test to REPL around.
    """
    def __init__(self):
        self.tasks = {k: ddict() for k in LANGS.keys()}
        self.mylang = None
        self.index = 1

    @classmethod
    def find(cls, EXISPATH, lang=None):
        c = cls()
        if lang and lang != "all":
            c.mylang = lang
            langExt = LANGS.get(lang)
        else:
            lang = None
            langExt = None
        skipDirs = ["arbiter", "node_modules"]
        allFiles = list()
        def walker(path):
            for f in glob.glob("{}/*".format(path)):
                fDirName = f.split('/')[-1]
                if os.path.isdir(f) and fDirName not in skipDirs:
                    walker(f)
                elif os.path.isfile(f):
                    ext = f.split('.')[-1] if "." in f else None
                    if ext is None:
                        continue
                    if lang != None:
                        if langExt == ext:
                            allFiles.append(f)
                    else:
                        if LANGS_EXT.get(ext, None):
                            allFiles.append(f)
        walker(EXISPATH)

        for f in allFiles:
            c._parse(f)
        return c

    def getTask(self, task, lang=None):
        """
        Return specific task for a specific language or None
        """
        l = lang or self.mylang
        return self.tasks.get(l, {}).get(task, None)

    def getTasks(self, lang=None, task=None, ordered=True):
        """
        Return generator for all matching tasks by language.
        Args:
            lang    : OPTIONAL, what language, None for all
            task    : OPTIONAL, provide a wildcard for task names
            ordered : OPTIONAL, Get them in index order

        TODO: retain relative ordering based on the file they came from?
        """
        baseName = task.split('*')[0] if task else None
        for l, tasks in self.tasks.iteritems():
            if lang is None or lang == l:
                for name, t in sorted(tasks.iteritems(), key=lambda x: x[1].index):
                    if(baseName is None or name.startswith(baseName)):
                        yield t

    def _addTask(self, t):
        """
        Adds this task to the proper places.
        """
        # Deal with js special (need browser and nodejs copies of the task)
        if t.langExt == "js":
            lang = ["nodejs", "browser"]
            for l in lang:
                if t.fullName() not in self.tasks[l]:
                    self.tasks[l][t.fullName()] = TaskSet()
                    self.tasks[l][t.fullName()].index = self.index
                    self.index += 1
                tcopy = Task.copy(t)
                tcopy.langName = l
                self.tasks[l][t.fullName()].add(tcopy)
        else:
            l = t.getLangName()
            if t.fullName() not in self.tasks[l]:
                self.tasks[l][t.fullName()] = TaskSet()
                self.tasks[l][t.fullName()].index = self.index
                self.index += 1

            self.tasks[l][t.fullName()].add(t)


    def _parse(self, fileName):
        lst = list()
        with open(fileName, "r") as fd:
            while(True):
                l = fd.readlines()
                if(not l):
                    break
                lst.extend(l)
        
        # Setup regex based on file type
        ftype = fileName.split(".")[-1]
        expect_re = _getExpectRe(ftype)
        
        # Run through the file
        FSM = "START"
        t = Task(fileName)

        lineNum = 1
        for c in lst:
            # Remove only right side whitespace
            c = c.rstrip()
            # Depending on the mode, check for matches
            #print(FSM, c)
            mStart = EX_START_RE.match(c)
            mExpect = expect_re.match(c)
            mEnd = EX_END_RE.match(c)
            if(FSM == "START"):
                if mStart:
                    # For a START match, looks like "Example Name[ stuff] - doc"
                    n, o, d = _parseStartMatch(mStart)
                    t.start(n, o, d)
                    FSM = "EXPECT"
                elif(mEnd):
                    print "Found error @ line {} in {}".format(lineNum, fileName)
                    raise Exception("Malformed code sequence - got expect or end, looking for start")
            
            elif(FSM == "EXPECT"):
                # Find the expect keyword
                if mExpect:
                    t.expect(mExpect.group(1), mExpect.group(2))
                    FSM = "END"
                    t.feed(c, lineNum)
                # They could also not provide an expect if they don't care
                elif(mEnd):
                    n, o = _parseEndMatch(mEnd)
                    t.end(n, o, lineNum)
                    self._addTask(t)
                    t = Task(fileName)
                    FSM = "START"
                elif(mStart):
                    print "Found error @ line {} in {}".format(lineNum, fileName)
                    raise Exception("Malformed code sequence - got start, looking for expect or end")
                else:
                    t.feed(c, lineNum)
            
            elif(FSM == "END"):
                # Found end, wrap it up and start over
                if mEnd:
                    n, o = _parseEndMatch(mEnd)
                    t.end(n, o, lineNum)
                    self._addTask(t)
                    t = Task(fileName)
                    FSM = "START"
                # Looking for end, but keep adding to the code for this Task
                else:
                    t.feed(c, lineNum)
                if(mStart):
                    print "Found error @ line {} in {}".format(lineNum, fileName)
                    raise Exception("Malformed code sequence - got start or expect, looking for end")
            lineNum += 1

class TaskSet:
    """
    Place holder for both halves of a task.

    These tasks are known by if they contain an expects or not.
    Each valid TaskSet will contain 2 Task objects, and one of those two Task objects
    must contain an expect. The expect tells us what to expect when we are CALLED (so subs
    and regs need expects).
    """
    def __init__(self):
        self.tasks = list()
        self.index = None

    def isValid(self):
        for t in self.tasks:
            if not t.valid:
                return False
        return True

    def details(self):
        name = self.getName()
        lang = LANGS_EXT[self.getLangExt()]
        if(self.isValid()):
            s = "TaskSet {} - {}\n".format(lang, name)
            for t in self.tasks:
                s += "\n---------------------------------------------\n"
                s += "  {}\n".format(t.action)
                s += "    {}".format(str(t).replace("\n", "\n    "))
            return s
        else:
            return "TaskSet {} - {} (INCOMPLETE)".format(lang, name)
    
    def getTask(self, action):
        """
        Return the task associated with the action provided, or None.
        """
        for t in self.tasks:
            if action == t.action:
                return t
        return None

    def getOrderedTasks(self):
        """
        Returns a list of the tasks in order to be called on properly.
        ie. Reg before Call, and Sub before Pub
        """
        lst = list()
        for i in ["register", "subscribe", "publish", "call"]:
            t = self.getTask(i)
            if t:
                lst.append(t)
        return lst
    
    def getLangExt(self):
        for t in self.tasks:
            if t.valid:
                return t.langExt
        return ""

    def getLangName(self):
        for t in self.tasks:
            if t.valid:
                return t.getLangName()
        return ""

    def getName(self):
        for t in self.tasks:
            if t:
                return t.fullName()
        return "EMPTY"
        
    def add(self, task):
        self.tasks.append(task)

    def __str__(self):
        name = self.getName()
        lang = self.getLangName()
        if(self.isValid()):
            return "# {:3d} {} - {}".format(self.index, lang, name)
        else:
            return "# {:3d} {} - {} (INCOMPLETE)".format(self.index, lang, name)

class Task:
    """
    Represents an individual Task that can be executed or documented
    """
    def __init__(self, fileName):
        self.langExt = fileName.split(".")[-1]
        self.langName = None
        self.fileName = fileName
        self.code = list()
        self.name = None
        self.opts = None
        self.doc = None
        self.valid = False
        self.expectType, self.expectVal = None, None
        self.expectLine = -1
        self.lineStart, self.lineEnd = None, None
        self.action = None

    @classmethod
    def copy(cls, task):
        """
        Return a full copy of this Task.
        """
        c = cls(task.fileName)
        c.__dict__.update(task.__dict__)
        return c

    def expect(self, eType, eVal):
        """
        Adds an expect to this Task (for recv tasks)
        """
        self.expectType = eType
        self.expectVal = eVal
        self.expectLine = len(self.code)
    
    def fullName(self):
        """
        Returns the full referenceable name that should be used - example: "Pub/Sub Objects"
        """
        if(not self.valid):
            raise Exception("Not a valid Task")
        return "{}{}".format(self.name, " " + self.opts if self.opts else "")

    def getLangName(self, wantJs=False):
        """For js/nodejs/browser support need to allow langName to be set in certain cases.
            if wantJs is True, then we will change browser and nodejs to js - this is for genDocs
        """
        if self.langName is None:
            l = LANGS_EXT.get(self.langExt, "Unknown")
        else:
            l = self.langName
        if wantJs and l in ("nodejs", "browser"):
            l = "js"
        return l
    
    def start(self, name, opts, doc):
        """
        The starting point of a task, it should be called with the results from a matched regex
        of the Example line.
        """
        self.name = name
        self.opts = opts
        self.doc = doc

    def feed(self, line, lineNum):
        """
        Add this line into the code, only valid if they called start at some point
        """
        if(self.name is None):
            raise Exception("Never called start!!")
        # If we have an action then ignore everything else
        if not self.action:
            # Search for the option to hardcode the action
            m = OPT_ACTION_RE.match(line)
            if m:
                self.action = m.group(1)
                # Don't save this to the code to be displayed
                return
            else:
                # Look for the important commands (reg/call/pub/sub)
                m = EXIS_CMDS_RE.match(line)
                if m:
                    self.action = m.group(1)[:-1].lower()
        # Track the line number (there are cases where we would have skipped lines
        # like if they defined options thats why we do this here rather than in start)
        if self.lineStart is None:
            self.lineStart = lineNum
        self.code.append(line)

    def end(self, name, opts, lineNum):
        """
        Ending call for a sequence of code, if this doesn't match the beginning call I will RAISE
        """
        if(self.name != name or self.opts != opts):
            print "{} @ line {}: {} != {}".format(self.fileName, lineNum, self.name, name)
            raise Exception("Incorrect ending sequence")
        self.valid = True
        self.lineEnd = lineNum
    
    def __str__(self):
        s = "{} - {}\n".format(self.fullName(), self.doc)
        s += "({} lines {}-{})\n".format(self.fileName, self.lineStart, self.lineEnd)
        s += "\n".join(self.code)
        return s

"""
    The classes that help organize all examples for all languages. They are organized
    into one Examples class which holds many ExampleFiles and each ExampleFiles class
    can hold many Task objects which represents the actual code to execute.
"""

import glob, re, os

from collections import defaultdict as ddict

# They provide "python" but we need to know the extension is "py"
LANGS = {"python": "py", "swift": "swift", "js": "js", "go": "go"}
# We found a file with extension "py" and need to know its "python"
LANGS_EXT = {"py": "python", "swift": "swift", "js": "js", "go": "go"}

# Match to the start of an example, pull out the name of the example, and the docs for it
EX_START_RE = re.compile("^.*Example (.*)? - (.*)$")
# Match to the end of an example, and pull out the name of the example
EX_END_RE = re.compile("^.*End Example (.*)$")
# Trying to match specifically on calls to the 4 primary function calls, with an optional space
# between the function name and (. Also dealing with lower/upper case, and trying to look for 
# functional calls specifically so we ignore comments and stuff like that
EXIS_CMDS_RE = re.compile(".*([Rr]egister *\(|[Cc]all *\(|[Ss]ubscribe *\(|[Pp]ublish *\().*$")

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
        self.tasks = {k: ddict(lambda: TaskSet()) for k in LANGS.values()}
        self.mylang = None

    @classmethod
    def find(cls, EXISPATH, lang=None):
        c = cls()
        if lang:
            c.mylang = lang
        thepath = lang or "*"
        
        allFiles = list()
        def walker(path):
            for f in glob.glob("{}/*".format(path)):
                if os.path.isdir(f) and "arbiter" not in f:
                    walker(f)
                elif os.path.isfile(f):
                    if LANGS_EXT.get(f.split('.')[-1], None) is not None:
                        allFiles.append(f)
        walker(EXISPATH)
        #print(allFiles)

        for f in allFiles:
            c._parse(f)
        return c

    def getTask(self, task, lang=None):
        """
        Return specific task for a specific language or None
        """
        l = lang or self.mylang
        t = self.tasks.get(LANGS[l])
        return self.tasks.get(LANGS[l]).get(task, None)

    def getTasks(self, lang=None, task=None):
        """
        Return generator for all matching tasks by language.
        """
        baseName = task.split('*')[0] if task else None
        for l, tasks in self.tasks.iteritems():
            if(lang is None or LANGS.get(lang, None) == l):
                for name, t in tasks.iteritems():
                    if(baseName is None or name.startswith(baseName)):
                        yield t

    def _addTask(self, t):
        """
        Adds this task to the proper places.
        """
        self.tasks[t.lang][t.fullName()].add(t)


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
                    t.start(n, o, d, lineNum)
                    FSM = "EXPECT"
                elif(mExpect or mEnd):
                    raise Exception("Malformed code sequence - got expect or end, looking for start")
            
            elif(FSM == "EXPECT"):
                # Find the expect keyword
                if mExpect:
                    t.expect(mExpect.group(1), mExpect.group(2))
                    FSM = "END"
                    t.feed(c)
                # They could also not provide an expect if they don't care
                elif(mEnd):
                    n, o = _parseEndMatch(mEnd)
                    t.end(n, o, lineNum)
                    self._addTask(t)
                    t = Task(fileName)
                    FSM = "START"
                elif(mStart):
                    raise Exception("Malformed code sequence - got start, looking for expect or end")
                else:
                    t.feed(c)
            
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
                    t.feed(c)
                if(mStart or mExpect):
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

    def isValid(self):
        for t in self.tasks:
            if not t.valid:
                return False
        return True

    def details(self):
        name = self.getName()
        lang = LANGS_EXT[self.getLang()]
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
    
    def getLang(self):
        for t in self.tasks:
            if t.valid:
                return t.lang
        return ""

    def getFullLang(self):
        return LANGS_EXT.get(self.getLang(), None)

    def getName(self):
        for t in self.tasks:
            if t:
                return t.fullName()
        return "EMPTY"
        
    def add(self, task):
        self.tasks.append(task)

    def __str__(self):
        name = self.getName()
        lang = LANGS_EXT[self.getLang()]
        if(self.isValid()):
            return "TaskSet {} - {}".format(lang, name)
        else:
            return "TaskSet {} - {} (INCOMPLETE)".format(lang, name)

class Task:
    """
    Represents an individual Task that can be executed or documented
    """
    def __init__(self, fileName):
        self.lang = fileName.split(".")[-1]
        self.fileName = fileName
        self.code = list()
        self.name = None
        self.opts = None
        self.doc = None
        self.valid = False
        self.expectType, self.expectVal = None, None
        self.expectLine = -1
        self.lineStart, self.lineEnd = 0, 0
        self.action = None

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

    def getLang(self):
        return LANGS_EXT[self.lang]
    
    def start(self, name, opts, doc, lineNum):
        """
        The starting point of a task, it should be called with the results from a matched regex
        of the Example line.
        """
        self.name = name
        self.opts = opts
        self.doc = doc
        self.lineStart = lineNum

    def feed(self, line):
        """
        Add this line into the code, only valid if they called start at some point
        """
        if(self.name is None):
            raise Exception("Never called start!!")
        # Look for the important commands (reg/call/pub/sub)
        m = EXIS_CMDS_RE.match(line)
        if(m):
            if(self.action is not None):
                print("!! Already have {} as type, now found {}".format(self.action, m.group(1)))
            self.action = m.group(1)[:-1].lower()
        
        self.code.append(line)

    def end(self, name, opts, lineNum):
        """
        Ending call for a sequence of code, if this doesn't match the beginning call I will RAISE
        """
        if(self.name != name or self.opts != opts):
            raise Exception("Incorrect ending sequence")
        self.valid = True
        self.lineEnd = lineNum
    
    def __str__(self):
        s = "{} - {}\n".format(self.fullName(), self.doc)
        s += "({} lines {}-{})\n".format(self.fileName, self.lineStart, self.lineEnd)
        s += "\n".join(self.code)
        return s

"""
    The classes that help organize all examples for all languages. They are organized
    into one Examples class which holds many ExampleFiles and each ExampleFiles class
    can hold many Task objects which represents the actual code to execute.
"""

import glob, re

from collections import defaultdict as ddict

LANGS = {"python": "py", "swift": "swift", "js": "js", "go": "go"}
LANGS_EXT = {"py": "python", "swift": "swift", "js": "js", "go": "go"}

EX_START_RE = re.compile("^.*Example (.*)? - (.*)$")
EX_END_RE = re.compile("^.*End Example (.*)$")

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

    @classmethod
    def find(cls, EXISPATH, lang):
        thepath = lang or "*"
        path = "{}/{}/example/*.{}".format(EXISPATH, thepath, LANGS.get(lang, "*"))
        c = cls()
        files = glob.glob(path)
        if(len(files) == 0):
            print("!! No example files found")
            return c
        
        for f in files:
            # Skip file extensions that don't match
            if(LANGS_EXT.get(f.split('.')[-1], None) is None):
                continue
            c._parse(f)
        return c

    def getTask(self, lang, task):
        """
        Return specific task for a specific language or None
        """
        t = self.tasks.get(LANGS[lang])
        return self.tasks.get(LANGS[lang]).get(task, None)
        

    def getTasks(self, lang=None, task=None):
        """
        Return generator for all matching tasks by language.
        """
        baseName = task.split('*')[0] if task else None
        for l, tasks in self.tasks.iteritems():
            if(LANGS.get(lang, None) == l or lang is None):
                for name, t in tasks.iteritems():
                    if(name.startswith(baseName) or baseName is None):
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
                if mEnd:
                    n, o = _parseEndMatch(mEnd)
                    t.end(n, o, lineNum)
                    self._addTask(t)
                    t = Task(fileName)
                    FSM = "START"
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
        self.taskRecv = None
        self.taskSend = None

    def isValid(self):
        #print(self.taskRecv, self.taskSend)
        return self.taskRecv is not None and self.taskSend is not None

    def details(self):
        name = self.getName()
        lang = LANGS_EXT[self.getLang()]
        if(self.isValid()):
            s = "TaskSet {} - {}\n".format(lang, name)
            s += "---------------------------------------------\n"
            s += "  Send\n"
            s += "    {}".format(str(self.taskSend).replace("\n", "\n    "))
            s += "\n---------------------------------------------\n"
            s += "  Recv\n"
            s += "    {}".format(str(self.taskRecv).replace("\n", "\n    "))
            s += "\n---------------------------------------------\n"
            return s
        else:
            return "TaskSet {} - {} (INCOMPLETE)".format(lang, name)
    
    def getLang(self):
        if self.taskSend:
            name = self.taskSend.lang
        elif self.taskRecv:
            name = self.taskRecv.lang
        else:
            name = ""
        return name

    def getName(self):
        if self.taskSend:
            name = self.taskSend.fullName()
        elif self.taskRecv:
            name = self.taskRecv.fullName()
        else:
            name = "EMPTY"
        return name
        
    def add(self, task):
        if(self.isValid()):
            raise Exception("TaskSet already valid but getting more tasks to add")
        
        if(task.expectType is not None):
            self.taskRecv = task
        else:
            self.taskSend = task

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
        self.code = ""
        self.name = None
        self.opts = None
        self.doc = None
        self.valid = False
        self.expectType, self.expectVal = None, None
        self.lineStart, self.lineEnd = 0, 0

    def expect(self, eType, eVal):
        """
        Adds an expect to this Task (for recv tasks)
        """
        self.expectType = eType
        self.expectVal = eVal
    
    def fullName(self):
        """
        Returns the full referenceable name that should be used - example: "Pub/Sub Objects"
        """
        if(not self.valid):
            raise Exception("Not a valid Task")
        return "{}{}".format(self.name, " " + self.opts if self.opts else "")
    
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
        self.code += "{}\n".format(line)

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
        s += "({} Lines {}-{})\n".format(self.fileName, self.lineStart, self.lineEnd)
        s += self.code
        return s


"""
    repl module

    Uses the coreappliances repler to execute code but in a local manner.
"""

import os

# Make sure we know where the core appliances are
APPLS = os.environ.get("EXIS_APPLIANCES", None)
if(APPLS is None):
    print("!! Need the $EXIS_APPLIANCES variable set to proceed")
    exit()

from utils import utils

WS_URL = os.environ.get("WS_URL", "ws://localhost:8000/ws")
DOMAIN = os.environ.get("DOMAIN", "xs.demo.test")
PYPATH = "{}/repler".format(APPLS)

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
    # Assume the last line of the code is enough info to judge indenting
    # Also assume they didn't use TABS!!!!!
    c = code[-1]
    return "{}exit()".format(" " * (len(c)-len(c.lstrip(' '))))

def _terminateSwift(code):
    pass

_terminate = {
    "py": _terminatePython,
    "swift": _terminateSwift
}

def getTestCode(task):
    """
    This function returns the properly formatted code needed to make the repl calls work.
    This means two things: 1) On call/pub examples it adds the proper leave() at the end
    and 2) it replaces the # Expect code with the proper assert.
    """
    # If there is an expect then replace it with an assert for testing
    if task.expectLine >= 0:
        expectLine = task.code[task.expectLine]
        replacement = _expect[task.lang](expectLine, task.expectType, task.expectVal)
        code = [a for a in task.code]
        code[task.expectLine] = replacement
    else:
        code = [a for a in task.code]
    
    # If this is a call/pub we need to add a leave function
    if task.action in ("publish", "call"):
        code.append(_terminate[task.lang](code))
    
    return "\n".join(code)


def executeTask(task):
    """
    Executes a provided task. (This is the real function to call if you have a task).
    This function sets up, calls, and cleans up an execution. It also does the validation on the results.

    Notes:
        For this to work the following env vars must exist:
            WS_URL         - the node to connect to
            EXIS_REPL_CODE - the code to run
            DOMAIN         - the domain (xs.demo.test)
            PYTHONPATH     - the path must be set to APPLS/repler/repl-{lang}/
    """
    lang = task.getLang()
    pypath = "{}/repl-{}/".format(PYPATH, lang)
    env = {
        "WS_URL": WS_URL,
        "DOMAIN": DOMAIN,
        "EXIS_REPL_CODE": getTestCode(task),
        "PYTHONPATH": pypath
    }

    return utils.oscall("./run2.sh", blocking=False, cwd=pypath, env=env)


def execute(ts, action):
    """
    Basic execute function. Executes the action from the TaskSet provided.
    """
    # Find the language
    lang = ts.getLang()

    # Get the right code to call
    t = ts.getTask(action)

    # Call the real exec function with this task
    return executeTask(t)

def executeAll(taskList, actionList):
    procs = list()
    for t, a in zip(taskList, actionList):
        print("{}: {}".format(a, t))
        procs.append(execute(t, a))
    
    print('Done calling exec...')
    # Go back through and terminate in reverse order
    for p in procs[::-1]:
        o, c, e = utils.procCommunicate(p)
        print(o, c, e)
    


def executePython(code):
    print("!! Python exec not implemented yet")

def executeSwift(code):
    print("!! Swift exec not implemented yet")
    

EXEC_FUNCS = {
    "python": executePython,
    "swift": executeSwift
}


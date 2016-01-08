#!/usr/bin/python
"""
This program provides the final word of how each programming language
should implement function calls while using Exis, so the name is actually quite fitting.

It can document and test real live examples of how to use Exis for every langugage.

Please run '$0 -ls all' for more info.

Environment Variables:
    EXISPATH - the path to the Exis repo

TODO:
    - Implement Object checking for Python
    - Implement other languages
"""

import sys, os, time, glob, argparse, re

from collections import defaultdict as ddict

EXISPATH = os.environ.get("EXISPATH", "..")
sys.path.append(EXISPATH)

from utils import functionizer as funcizer
from utils import utils

import exampler, repl


def findTasks(lang=None, task=None, verbose=False):
    """
    Searches for all example files in the Exis repo.
    Args:
        OPTIONAL lang : One of {python, go, js, swift} or None which means get all.
        OPTIONAL task : Matching task with wildcard support (ie. "Pub/Sub*")
        OPTIONAL verbose : T/F on verbose printing
    """
    examples = exampler.Examples.find(EXISPATH, lang)
    for t in examples.getTasks(lang, task):
        if(verbose):
            print(t.details())
        else:
            print(t)
    
def findTask(lang, task):
    """
    Finds and prints reference to a specific task in a specific language.
    """
    examples = exampler.Examples.find(EXISPATH, lang)
    ts = examples.getTask(task)
    if(ts):
        print(ts.details())
    else:
        print("No Task found")

TASK_DEF_RE = re.compile("(.*)? (.*):(.*)$")
def _ripTaskDef(t):
    """
    Internal function that rips apart a task definition like "language action:example"
    """
    m = TASK_DEF_RE.match(t)
    if not m:
        print("!! Malformed task: {}".format(t))
        return [None] * 3
    return m.groups()

def test(*tasks):
    """
    Executes potentially many tasks provided as individual arguments.
    NOTE: Please order your tasks intelligently - this means place subs/regs before calls/pubs.
    Arguments:
        tasks... : potentially many tasks to execute, in the format "language action:example name"
        -v       : if the last arg is -v then print extra data about the tasks found

    Example:
        test("python register:Reg/Call", "swift call:Reg/Call")
            This will setup the reg of the Reg/Call example in python and call it with the Reg/Call
            example from Swift.

        test("python register:Reg/Call Basic", "swift publish:Pub/Sub")
            This will setup the python reg of "Reg/Call Basic" and the swift publish from Pub/Sub
            obviously nothing will happen and that is the point - know what you are doing...
    """
    if(tasks[-1] == "-v"):
        tasks = tasks[:-1]
        verbose = True
    examples = exampler.Examples.find(EXISPATH)
    
    taskList = list()
    actionList = list()
    for t in tasks:
        lang, action, taskName = _ripTaskDef(t)
        ts = examples.getTask(taskName, lang)
        if not ts:
            print("!! No TaskSet found")
        else:
            taskList.append(ts)
            actionList.append(action)
    
    # Exec all of them
    repl.executeAll(taskList, actionList)

def testAll(lang):
    """
    Executes all found tests for the language provided.
    """
    examples = exampler.Examples.find(EXISPATH, lang)
    for t in examples.getTasks(lang):
        repl.executeTaskSet(t)
        print('-'*80)

def cleanup():
    """
    Cleans up all tmp test folders.
    """
    print "Cleaning up tmp directories:"
    repl.cleanupTests()
    print "DONE"

def genDocs():
    """
    Takes all code found and generates a JSON style doc system that can be consumed by the website.
    Looks like:
           {
            TaskName: {
                    lang: {
                        action: {
                            file: str,
                            lines: str,
                            code: ...,
                            expectType: str,
                            expectVal: str
                        }
                    }
                }
            }
    """
    examples = exampler.Examples.find(EXISPATH)

    docs = ddict(lambda: {k: dict() for k in exampler.LANGS.keys()})
    for t in examples.getTasks():
        for tt in t.tasks:
            d = dict(file=tt.fileName, lineStart=tt.lineStart, lineEnd=tt.lineEnd, code=tt.code, 
                    expectType=tt.expectType, expectVal=tt.expectVal)
            docs[t.getName()][t.getFullLang()][tt.action] = d

    # Strip out anything that isn't populated
    for k, v in docs.iteritems():
        l = list()
        for kk, vv in v.iteritems():
            if not vv:
                l.append(kk)
        for ll in l:
            v.pop(ll)
    
    print utils.jsonPretty(docs)

def _getArgs():
    parser = argparse.ArgumentParser(description=__doc__)
    return parser


if __name__ == "__main__":
    parser = _getArgs()
    funcizer.init(parser)
    args = parser.parse_args()
    
    # Now make the call that decides which of our functions to run
    funcizer.performFunctionalize(args, __name__, modSearch="__main__")
    
    

#!/usr/bin/python
"""
    Arbiter:
    
    Before you scoff at the name, this program provides the final word of how each programming language
    should implement function calls while using Exis, so the name is actually quite fitting.
    
    It can document and test real live examples of how to use Exis for every langugage.

    Please run '$0 -ls all' for more info.

    Environment Variables:
        EXISPATH - the path to the Exis repo
"""

import sys, os, time, glob, argparse

EXISPATH = os.environ.get("EXISPATH", "..")
sys.path.append(EXISPATH)

from utils import functionizer as funcizer
from utils import utils
import exampler


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
    ts = examples.getTask(lang, task)
    if(ts):
        print(ts.details())
    else:
        print("No Task found")


def _getArgs():
    parser = argparse.ArgumentParser(description=__doc__)
    return parser


if __name__ == "__main__":
    parser = _getArgs()
    funcizer.init(parser)
    args = parser.parse_args()
    
    # Now make the call that decides which of our functions to run
    funcizer.performFunctionalize(args, __name__, modSearch="__main__")
    
    

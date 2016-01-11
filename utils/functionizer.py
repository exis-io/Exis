import sys, argparse, traceback, json

"""
    This module helps allow any python script to be called from the command line
    in a uniform way. By calling the @functionalize function and passing in the module
    name, all functions can now be called from the command line with a "-f" and args
    passed to it in order with "-a" arguments. Also all valid functions will be listed
    with a search feature if a "-ls" is provided.
"""
def _parseValue(key):
    """
        Description:
            Attempts to parse the key value, so if the string is 'False' it will parse a boolean false.

        Arguments:
            @key : the string key to parse

        Returns:
            The parsed value. If no parsing options are available it just returns the same string.
    """
    # Is it an int?
    try:
        i = int(key)
        return i
    except:
        pass
    
    # Is it a float?
    if('.' in key):
        try:
            f = float(key)
            return f
        except:
            pass
    
    # Is it a boolean?
    if(key == 'True' or key == 'true'):
        return True
    if(key == 'False' or key == 'false'):
        return False
    
    # Is it None?
    if(key == 'None' or key == 'null'):
        return None

    # Is it JSON?
    try:
        j = json.loads(key)
        return j
    except:
        pass

    # Otherwise, its just a string:
    return key

def _jsonPretty(j):
    """
        Returns a string of a JSON object in 'pretty print' format fully indented, and sorted.
    """
    return json.dumps(j, sort_keys=True, indent=4, separators=(',', ': '))

def init(arg):
    """
        Adds the required arguments to an argparse.ArgumentParser() object so the module can be functionalized.
    """
    arg.add_argument('-ls', '--list', help='List functions: Takes "all", "partialName*", "exactName"', type=str)
    arg.add_argument('-f', '--func', help='Function to call', type=str)
    arg.add_argument('-a', '--args', help='Argument list for the function', action='append', type=str)
    arg.add_argument('-kw', '--kwargs', help='Keyword arg list, like "-kw k=b" or "-kw k=JSON"', action='append', type=str)
    arg.add_argument('-q', help='Quiet, use if calling from a script', action='store_true')
    arg.add_argument('-?', dest="helpme", help='Print help for function', action='store_true')
    arg.add_argument('--printResult', help='Print the return value, format if needed', choices=['str', 'json'], type=str, default=None)

def _getModFunctions(modName, modSearch):
    """
        Takes the module name and tries to identify a list of functions to return.
    """
    # First find all callable functions they want
    try:
        mod = sys.modules[modName]
        modNames = dir(mod)
        callables = []
        for m in modNames:
            a = getattr(mod, m)
            if(hasattr(a, '__call__') and hasattr(a, '__class__')):
                if(a.__module__ == modSearch and a.__name__[0] != "_"):
                    callables.append(a)
        return callables
    except Exception as e:
        print('!! Unable to functionalize the module: %s' % str(e))
        return None

def _printHelp(mod, func):
    if(not hasattr(mod, func)):
        print('No %s function found' % func)
        return
    rfunc = getattr(mod, func)
    print('Function: %s' % rfunc.__name__)
    # Sometimes we have wrappers around our functions for different reasons
    # in this case, if __doc__ is empty, check for "_func" too
    if(rfunc.__doc__ == None):
        if(hasattr(mod, "_%s" % func)):
            print('(Docs found for function _%s)' % func)
            rfunc = getattr(mod, "_%s" % func)
    print('    %s' % rfunc.__doc__)

def performFunctionalize(args, modName, modSearch="__main__", preArgs=(), postArgs=()):
    """Takes an argparse object, adds our required args for functioning, then calls the proper functions"""
    funcsList = args.list
    
    mod = sys.modules[modName]
    if(funcsList):
        funcs = _getModFunctions(modName, modSearch)
        if('*' in funcsList):
            funcsList = funcsList.replace('*', '')
            search = True
        else:
            search = False
        for f in funcs:
            if(funcsList == 'all' or (search and funcsList in f.__name__) or (not search and funcsList == f.__name__)):
                print('============================================================================================')
                _printHelp(mod, f.__name__)

        return

    
    #
    # Run the function as a command
    #
    if(args.func):
        if(not hasattr(mod, args.func)):
            print('No %s function found' % args.func)
            return
        
        func = args.func
        rfunc = getattr(mod, func)
        
        # Get any args they want used
        fargs = None
        if(args.args):
            fargs = [_parseValue(a) for a in args.args]
        
        # Deal with kwargs
        kwargs = dict()
        if(args.kwargs):
            for kw in args.kwargs:
                k, w = kw.split('=', 1)
                kwargs[k] = _parseValue(w)
        
        # Print out the docs about the function
        if(args.helpme):
            _printHelp(mod, func)
            return
        
        try:
            # Build arguments to send them
            theArgs = list()
            if(preArgs):
                theArgs += list(preArgs)
            if(fargs):
                theArgs += list(fargs)
            if(postArgs):
                theArgs += list(postArgs)
            
            # Call the function, if no args make special call (couldn't figure out another way)
            if(theArgs and kwargs):
                res = rfunc(*theArgs, **kwargs)
            elif(theArgs and not kwargs):
                res = rfunc(*theArgs)
            elif(not theArgs and kwargs):
                res = rfunc(**kwargs)
            else:
                res = rfunc()
            
            # Print results
            if(args.printResult == 'str'):
                print(res)
            elif(args.printResult == 'json'):
                print(_jsonPretty(res))
        except Exception as e:
            t = ", ".join(theArgs) + ", " if theArgs else ""
            t += ", ".join(["{}={}".format(k, v) for k, v in kwargs.iteritems()])
            print "Exception when calling {}({})".format(args.func, t)
            print e
            _printHelp(mod, func)
            traceback.print_exc()
    else:
        print('Call with "-h" for help')
        return
    

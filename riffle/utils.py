'''
Random utilities
'''

import random

def newID(n=1):
    ''' Returns n random unsigned integers to act as Callback Ids '''
    return random.getrandbits(53) if n == 1 else tuple([random.getrandbits(53) for x in range(n)])


class Error(Exception):
    def __init__(self, *args):
        super(Error, self).__init__(*args)
        self.message = Error.messageFromArgs(args)

    def __str__(self):
        return self.message

    @classmethod
    def messageFromArgs(_class, args):
        """
        Find the human-readable message in a list of args.

        args must be a tuple or list of any length.
        """
        if len(args) == 0:
            return ""
        elif len(args) == 1:
            return str(args[0])
        else:
            first = str(args[0])
            if first.startswith("wamp.error"):
                return str(args[1])
            else:
                return first


class SyntaxError(Error):
    pass

class CuminError(Error):
    pass

class Unimplemented(Error):
    pass

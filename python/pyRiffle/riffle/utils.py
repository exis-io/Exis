'''
Random utilities
'''

import random

def newID(n=1):
    ''' Returns n random unsigned integers to act as Callback Ids '''
    return random.getrandbits(53) if n == 1 else tuple([random.getrandbits(53) for x in range(n)])

class RiffleError(Exception):
    pass

class CuminError(Exception):
    pass

class Unimplemented(RiffleError):
    pass

# Example Want Definitions Recv - defines how to use want for receiving actions
# ARBITER set action defs

# In Python you must import want to use as
# a decorator
from riffle import want

# After importing want, you simply decorate 
# any function with it.
@want(str)
def myFunction(aString):
    print(aString) # Guaranteed str
# resulting function will only be called with
# the args if they are of the type specified

# NOTE: each @want must decorate a function
# below, we removed them for clarity

# Nothing is returned
@want()

# The primitives
@want(str)
@want(int)
@want(float)
@want(bool)

# Collections
@want(list) # A list of anything
@want(dict) # A dict containing anything

# None is returned
@want(None)

# Many arguments
@want(str, int, float) # 3 args: str, int, float
@want(str, [int]) # 2 args: str, list of many int's

# End Example Want Definitions Recv

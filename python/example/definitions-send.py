# Example Want Definitions Send - defines how to use want for sending actions
# ARBITER set action defs

# In Python you must import riffle
import riffle

# First setup your domain
app = riffle.Domain("xs.demo.test")
me = riffle.Domain("me", superdomain=app)
me.join() # Make the connection as me
# Create a domain reference to who you want to 
# communicate with
ex = riffle.Domain("example", superdomain=app)

# Since any call function can return values,
# you can specify type arguments.
myStr = ex.call("hello", "arg").wait(str)
# myStr is guaranteed to be a str, if the
# registered function (hello) returns anything
# else it will not return properly.

# You expect nothing as a return
arg = ex.call("hello").wait()

# You can pass any primitive
arg = ex.call("hello").wait(str)
arg = ex.call("hello").wait(int)
arg = ex.call("hello").wait(float)
arg = ex.call("hello").wait(bool)

# Collections
arg = ex.call("hello").wait(list)
arg = ex.call("hello").wait(dict)

# None is returned
arg = ex.call("hello").wait(None)

# Many arguments
# a is str, b is int, c is float
a, b, c = ex.call("hello").wait(str, int, float)
# d is str, e is a list of int's
d, e = ex.call("hello").wait(str, [int])

# End Example Want Definitions Send

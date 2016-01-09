# Template Before
import riffle
from riffle import want

riffle.SetFabricLocal()
riffle.SetLogLevelDebug()

class GenericDomain(riffle.Domain):

    def onJoin(self):
        # End Template Before
        
        # ARBITER for _ARG_ in JSON ["Hello World", 0, True, 1.0, ["A"]]
        # ARBITER iter _ARGNAMES_ in JSON ["String", "Int", "Boolean", "Float", "ListOfStrings"]
        # ARBITER for _WAIT_ in RAW str, int, bool, float, [str]
        # ARBITER iter _WAITNAMES_ in JSON ["String", "Int", "Boolean", "Float", "ListOfStrings"]
        # Example Reg/Call Basic _ARGNAMES_ _WAITNAMES_ - generated test cases that don't catch exceptions
        s = backend.call("reg_ARGNAMES__WAITNAMES_", _ARG_).wait(_WAIT_)
        print _ARGNAMES_ == _WAITNAMES_ # Expects a bool, like True
        # End Example Reg/Call Basic _ARGNAMES_ _WAITNAMES_
        # ARBITER end _WAIT_
        # ARBITER end _ARG_

        
        
        # ARBITER for _ARG_ in JSON ["Hello World", 0, True, 1.0, ["A"]]
        # ARBITER iter _ARGNAMES_ in JSON ["String", "Int", "Boolean", "Float", "ListOfStrings"]
        # ARBITER for _WAIT_ in RAW str, int, bool, float, [str]
        # ARBITER iter _WAITNAMES_ in JSON ["String", "Int", "Boolean", "Float", "ListOfStrings"]
        # Example Reg/Call Exception _ARGNAMES_ _WAITNAMES_ - generated test cases that do catch exceptions
        try:
            s = backend.call("reg_ARGNAMES__WAITNAMES_", _ARG_).wait(_WAIT_)
            print _ARGNAMES_ == _WAITNAMES_ # When _ARGNAMES_ == _WAITNAMES_: Expects a bool, like True
        except:
            print "Exception" # When _ARGNAMES_ != _WAITNAMES_: Expects a str, like "Exception"
        # End Example Reg/Call Exception _ARGNAMES_ _WAITNAMES_
        # ARBITER end _WAIT_
        # ARBITER end _ARG_


        print "___SETUPCOMPLETE___"

# Template After
app = riffle.Domain("xs.demo.test") # ARBR $DOMAIN replaces "xs.demo.test"

client = riffle.Domain("client", superdomain=app)
backend = riffle.Domain("backend", superdomain=app)

GenericDomain("client", superdomain=app).join() # ARBR $SUBDOMAIN replaces "client"
# End Template After

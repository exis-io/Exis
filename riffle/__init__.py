#
# Identify the platform so that we can load the right pymantle.so.
#
import os
import platform
import sys
if platform.architecture() == ("64bit", "ELF"):
    libdir="linux-x86_64"
elif platform.architecture() == ("32bit", "ELF"):
    libdir="linux-386"
    print("Warning: for 32-bit platforms, you must set GODEBUG in your environment.")
    print("Try 'export GODEBUG=cgocheck=0' if you experience problems.")
else:
    raise Exception("Your platform ({}) is not currently supported."
            .format(platform.platform()))

# Find the directory where riffle is installed and then add the appropriate
# subdirectory to the system path.
riffledir = os.path.dirname(__file__)
sys.path.append(os.path.join(riffledir, libdir))


from crust import Domain
from model import ModelObject
from cumin import want
from utils import Error, CuminError

from pymantle import SetLogLevelErr, SetLogLevelWarn, SetLogLevelInfo, SetLogLevelDebug, SetLogLevelApp, SetLogLevelOff
from pymantle import SetFabricDev, SetFabricSandbox, SetFabricProduction, SetFabricLocal, SetFabric
from pymantle import Application as log

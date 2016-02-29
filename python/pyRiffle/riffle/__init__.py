#
# Identify the platform so that we can load the right pymantle.so.  We will
# detect the architecture and then add the corresponding subdirectory to the
# system path.
#
# If the developer built pymantle.so from source, that version will be loaded
# regardless of where the platform-detection points us.
#
import os
import platform
import sys
if platform.architecture() == ("64bit", "ELF"):
    libdir = "linux-x86_64"
elif platform.architecture() == ("32bit", "ELF"):
    libdir = "linux-386"
    print("Warning: for 32-bit platforms, you must set GODEBUG in your environment.")
    print("Try 'export GODEBUG=cgocheck=0' if you experience problems.")
elif platform.system() == "Darwin" and platform.machine() == "x86_64":
    libdir = "Darwin-x86_64"
else:
    # Unsupported platforms can still work if the developer built pymantle.so
    # from source.
    libdir = None
    print("Warning: your platform ({}) is not currently supported.".format(
        platform.platform()))

# Find the directory where riffle is installed and then add the appropriate
# subdirectory to the system path.
if libdir is not None:
    riffledir = os.path.dirname(__file__)
    sys.path.append(os.path.join(riffledir, libdir))


from crust import Domain
from model import ModelObject
from cumin import want
from utils import Error, CuminError

from pymantle import SetLogLevelErr, SetLogLevelWarn, SetLogLevelInfo, SetLogLevelDebug, SetLogLevelApp, SetLogLevelOff
from pymantle import SetFabricDev, SetFabricSandbox, SetFabricProduction, SetFabricLocal, SetFabric
from pymantle import Application as log

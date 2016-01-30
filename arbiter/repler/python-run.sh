#!/bin/bash

cat >main.py <<EOF

import riffle
from riffle import want

riffle.SetFabric("$WS_URL")
riffle.SetLogLevelApp()
$EXIS_SETUP

class Test(riffle.Domain):
    def onJoin(self):

$EXIS_REPL_CODE
        
        print "___SETUPCOMPLETE___"

if __name__ == "__main__":
    app = riffle.Domain("$DOMAIN")
    client = riffle.Domain("example", superdomain=app)
    backend = riffle.Domain("example", superdomain=app)

    Test("example", superdomain=app).join()

EOF

echo "___BUILDCOMPLETE___"

python -u main.py

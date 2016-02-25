#!/bin/bash

if [ ! -d venv ]; then
    virtualenv venv
    source venv/bin/activate
    pip install --requirement requirements.txt
else
    source venv/bin/activate
    pip install --requirement requirements.txt
fi



# Make these options configurable.
#--tags=-production-only    : do not run tests tagged as production-only
#--tags=-wip                : do not run tests tagged as works in progress

behave --tags=-production-only --tags=-wip

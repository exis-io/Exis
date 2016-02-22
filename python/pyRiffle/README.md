# pyRiffle

All our docs live at [docs.exis.io](http://docs.exis.io). 

Riffle functionality for python. 

1. Install [Go][https://golang.org/dl/].

2. Install [GoPy][go get github.com/go-python/gopy].

3. Set a GOPATH: export GOPATH=some/path/to/go/src. This is where Go saves download packages. Make sure to add GOPATH/bin to your path. 

4. Link core libraries to Gopath: python stump.py init. Alternatively, go get github.com/exis-io/core may also work, but this won't keep the directory up to date.

5. Compile riffle core. In top level directory: `make python`. The core libraries are rebuilt every time this make is run. You only have to do it once, at the start, then you can skip to....

6. Install pyRiffle locally. In `python/pyRiffle` run `sudo pip install -e .`

7. Compile and run sample project. In python/example: `python receiver.py` and `python sender.py`.


## Installation on Mac OSX

1. Currently, pyRiffle requires Apple's default Python interpreter.  If you have python installed through Homebrew, it must be removed in order to use pyRiffle.  We realize this may inconvenience more than a few developers and are working to fix this limitation.

    `brew rm python`

2. We highly recommend using [virtualenv][https://virtualenv.readthedocs.org/en/latest/] for dependency management.  Install and activate a virtual environment.  Please see the [User Guide][https://virtualenv.readthedocs.org/en/latest/userguide.html] if you are unfamiliar with the virtualenv workflow.

    ```
    sudo pip install virtualenv
    virtualenv venv
    source venv/bin/activate
    ```

3. Install pyRiffle

    `pip install pyRiffle`

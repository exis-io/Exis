# pyRiffle

Riffle functionality for python. 

1. Install [Go][https://golang.org/dl/] and gopy. 

2. Set a GOPATH: export GOPATH=some/path/to/go/src. This is where Go saves download packages.

3. Link core libraries to Gopath: python stump.py init. Alternatively, go get github.com/exis-io/core may also work, but this won't keep the directory up to date.

4. Compile riffle core. In top level directory: `make python`. The core libraries are rebuilt every time this make is run. You only have to do it once, at the start, then you can skip to....

5. Install pyRiffle locally. In `python/pyRiffle` run `sudo pip install -e .`

6. Compile and run sample project. In python/example: `python receiver.py` and `python sender.py`.

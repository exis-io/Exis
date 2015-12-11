# swiftRiffle (Ubuntu, swift 2.2)

This section is a work in progress and may be subject to change. It describes building swiftRiffle with Swift 2.2. 

**1**. Install [Go][https://golang.org/dl/].

**2**. Set a GOPATH: `export GOPATH=some/path/to/go/src`. This is where Go saves download packages. 

**3**. Link core libraries to Gopath: `python stump.py init`. Alternatively, `go get github.com/exis-io/core` may also work, but this won't keep the directory up to date. 

**4**. Compile riffle core. In top level directory: `make swift`. The core libraries are rebuilt every time this make is run. You only have to do it once, at the start, then you can skip to....

**5**. Compile swiftRiffle. In `swift/swiftRiffle`: `make`. Note: if you `make` in the top level directory swiftRiffle is automatically built as well. 

**6**. Compile and run sample project. In `swift/example`: `make` and then `./run`. 


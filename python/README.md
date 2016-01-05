# Python Riffle

Python libraries for working with Riffle. 


## Dependencies
```
go get github.com/go-python/gopy
which gopy # If this doesn't work you need to add $GOPATH/bin to your $PATH
```

## Installation
```
# From Exis repo
make python
cd python/pyRiffle
sudo pip install -e .
```

## Known issues

You may have a problem using this with Mac OS X. This happens most often because of an issue
between Apple's Python release and what most people use which would be like homebrew...

Here is one thing to try:
```
export PKG_CONFIG_PATH=/System/Library/Frameworks/Python.framework/Versions/2.7/lib/pkgconfig
```

Which looks something like:
```
prefix=/System/Library/Frameworks/Python.framework/Versions/2.7
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: Python
Description: Python library
Requires:
Version: 2.7
Libs.private: -ldl  -framework CoreFoundation
Libs: -L${libdir} -lpython2.7
```

# Javascript Riffle Libraries

This directory contains all javascript Riffle libraries. 

All our docs live at [docs.exis.io](http://docs.exis.io). 

## Installation

* Go installed
  * GOPATH and GOBIN are set properly
* Nodejs installed
* Install `go get -u github.com/gopherjs/gopherjs`
* From the Exis directory, run `make js`
* cd to `js/jsRiffle/`
* Run `npm install` to make sure you can find dependencies
* Run `sudo npm link` to make the `jsriffle` package globally available on your machine
* `cd ../examples/`
* Run `npm install` - now you should be able to build
* Run `node server.js` and `node client.js`



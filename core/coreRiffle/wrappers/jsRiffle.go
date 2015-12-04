// package name: reef
package main

import (
	"github.com/damouse/goriffle"
	"github.com/gopherjs/gopherjs/js"
)

/*
Works-- call with
	riffle.go.Receiver("Publish")
	var go = require('./go.js');
	exports.go = global.core;
*/

// Required main method
func main() {
	js.Global.Set("core", map[string]interface{}{
		"Receiver": goriffle.ExternalReceive,
		"Native":   Connector,
	})
}

// //export Connector
func Connector(url string, domain string) string {

	go func() {
		goriffle.PConnector(url, domain)
		// goriffle.PSubscribe("xs.damouse.hello")
		// fmt.Println("Done")
	}()
	return "Thanks"
}

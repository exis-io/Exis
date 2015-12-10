//
//  Riffle.swift
//  RiffleTest
//
//  Created by damouse on 12/10/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation

var NODE = "wss://node.exis.io:8000/wss"
var SOFTNODE = false
var DEBUG = false
var STDERR = false


public class Riffle {
    // Static configuration class
    
    public static func setDevFabric(node: String = "ws://ubuntu@ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws") {
        NODE = node
        SOFTNODE = true
    }
    
    public static func setFabric(url: String) {
        NODE = url
    }
    
    public static func setDebug() {
        DEBUG = true
    }
    
    static func debug(s: String) {
        if DEBUG {
            out("DEBUG: \(s)")
        }
    }
    
    static func warn(s: String) {
        out("WARN: \(s)")
    }
    
    static func panic(s: String) {
        out("PANIC: \(s)")
    }
    
    static func out(s: String) {
        if STDERR {
            fputs("\(s)\n", __stderrp)
        } else {
            print(s)
        }
    }
}





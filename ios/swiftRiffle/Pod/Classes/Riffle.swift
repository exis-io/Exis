//
//  Riffle.swift
//  Pods
//
//  Created by Mickey Barboi on 9/25/15.
//
//

import Foundation
import Darwin

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

// Sets itself as the delegate if none provided
@objc public protocol RiffleDelegate {
    func onJoin()
    func onLeave()
}





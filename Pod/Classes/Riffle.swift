//
//  Riffle.swift
//  Pods
//
//  Created by Mickey Barboi on 9/25/15.
//
//

import Foundation

var NODE = "wss://node.exis.io:8000/wss"
var SOFTNODE = false
var DEBUG = false


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
            print(s)
        }
    }
    
    static func warn(s: String) {
        print("WARN: \(s)")
    }
    
    static func panic(s: String) {
        print("PANIC: \(s)")
    }
}

// Sets itself as the delegate if none provided
@objc public protocol RiffleDelegate {
    func onJoin()
    func onLeave()
}





//
//  main.swift
//  RiffleTest
//
//  Created by Mickey Barboi on 11/22/15.
//  Copyright © 2015 exis. All rights reserved.
//

/*
TODO:
    Integrate with main swiftRiffle lib for testing
    Make conditional compilers for ios and osx
    Cleanup and integrate new changes with goRiffle
    Implement Domain class in goRiffle
    Implment Call, Unreg, Unsub
*/

import Foundation

// Helper methods
//(str as NSString).UTF8String

let url = "ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws"
let domain = "xs.damouse"


extension String {
    func cString() -> UnsafeMutablePointer<Int8> {
        let cs = (self as NSString).UTF8String
        return UnsafeMutablePointer(cs)
    }
}

// Interface object for interacting with goRiffle
class Gopher: NSObject {
    var handlers: [Int64: (AnyObject) -> (AnyObject?)] = [:]

    
    func subscribe(domain: String, fn: (AnyObject) -> ()) {
        
        #if os(OSX)
        let s = Subscribe(domain.cString())
        let d = NSData(bytes: s.data , length: NSNumber(longLong: s.len).integerValue)
        let data = try! NSJSONSerialization.JSONObjectWithData(d, options: .AllowFragments) as! NSDecimalNumber
        #endif
        
        handlers[data.longLongValue] = { (a: AnyObject) -> (AnyObject?) in
            fn(a)
            return nil
        }
    }
    
    func register(domain: String, fn: (AnyObject) -> (AnyObject)) {
        
        #if os(OSX)
        let s = Register(domain.cString())
        let d = NSData(bytes: s.data , length: NSNumber(longLong: s.len).integerValue)
        let data = try! NSJSONSerialization.JSONObjectWithData(d, options: .AllowFragments) as! NSDecimalNumber
        #endif
        
        // small trick to use homogenous handlers
        handlers[data.longLongValue] = { (a: AnyObject) -> (AnyObject?) in
            return [fn(a)]
        }
    }
    
    func receive() {
        while true {
            let s = Recieve()
            let d = NSData(bytes: s.data , length: NSNumber(longLong: s.len).integerValue)
            let data = try! NSJSONSerialization.JSONObjectWithData(d, options: .AllowFragments) as! [String: AnyObject]
            
            // All these need to be dispatched to background
            
            if let results = handlers[Int64(data["id"] as! Double)]!(data["data"]!) {
                let json: [String: AnyObject] = [
                    "id": String(Int64(data["request"] as! Double)),
                    "ok": "",
                    "result": results
                ]

                let out = try! NSJSONSerialization.dataWithJSONObject(json, options: .PrettyPrinted)

                let slice = GoSlice(data: UnsafeMutablePointer<Void>(out.bytes), len: NSNumber(integer: out.length).longLongValue, cap: NSNumber(integer: out.length).longLongValue)
                Yield(slice)

            }
            
            // todo: call
        }
    }
}


let ret = Connector(url.cString(), domain.cString());


let g = Gopher()

g.register("xs.damouse.go/sub") { (obj: AnyObject) -> AnyObject in
    print("Call received: \(obj)")
    return "Bootle"
}

// Threading implementation
let thread = NSThread(target: g, selector: "receive", object: nil)
thread.start()
NSRunLoop.currentRunLoop().run()


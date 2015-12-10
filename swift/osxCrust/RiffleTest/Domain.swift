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


// Sets itself as the delegate if none provided
@objc public protocol RiffleDelegate {
    func onJoin()
    func onLeave()
}

extension String {
    func cString() -> UnsafeMutablePointer<Int8> {
        let cs = (self as NSString).UTF8String
        return UnsafeMutablePointer(cs)
    }
}

// Interface object for interacting with goRiffle
class Domain: NSObject, RiffleDelegate {
    var mantleDomain: UnsafeMutablePointer<Void>
    var handlers: [Int64: (AnyObject) -> (AnyObject?)] = [:]
    
    var delegate: RiffleDelegate?
    
    
    init(name: String) {
        mantleDomain = NewDomain(name.cString())
        
        super.init()
        delegate = self
    }
    
    func onJoin() {
        print("Domain joined!")
    }
    
    func onLeave() {
        print("Domain left!!")
    }
    
    func subscribe(domain: String, fn: (AnyObject) -> ()) {
        let (cb, _) = invocation(Subscribe(mantleDomain, domain.cString()))
        
        handlers[cb] = { (a: AnyObject) -> (AnyObject?) in
            fn(a)
            return nil
        }
    }
    
    func register(domain: String, fn: (AnyObject) -> (AnyObject?)) {
        let (cb, _) = invocation(Register(mantleDomain, domain.cString()))
        
        handlers[cb] = { (a: AnyObject) -> (AnyObject?) in
            return fn(a)
        }
    }
    
    func receive() {
        while true {
            let s = Recieve()
            
            let d = NSData(bytes: s.data , length: NSNumber(longLong: s.len).integerValue)
            let data = try! NSJSONSerialization.JSONObjectWithData(d, options: .AllowFragments) as! [AnyObject]
            print(data)
            
            // All these need to be dispatched to background
            
            if let results = handlers[data[0].longLongValue]!(data[1]) {
//                let json: [String: AnyObject] = [
//                    "id": String(Int64(data["request"] as! Double)),
//                    "ok": "",
//                    "result": results
//                ]

//                let out = try! NSJSONSerialization.dataWithJSONObject(json, options: . PrettyPrinted)
//
//                let slice = GoSlice(data: UnsafeMutablePointer<Void>(out.bytes), len: NSNumber(integer: out.length).longLongValue, cap: NSNumber(integer: out.length).longLongValue)
//                Yield(slice)

            }
            
            // todo: call
        }
    }
    
    func join() {
        let (cb, eb) = invocation(Join(mantleDomain))
        
        handlers[cb] = { (a: AnyObject) -> (AnyObject?) in
            self.delegate!.onJoin()
            return nil
        }
        
        handlers[eb] = { (a: AnyObject) -> (AnyObject?) in
            print("Unable to join!")
            return nil
        }
        
        let thread = NSThread(target: self, selector: "receive", object: nil)
        thread.start()
        NSRunLoop.currentRunLoop().run()
    }
}



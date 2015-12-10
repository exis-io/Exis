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

class Domain: NSObject, RiffleDelegate {
    var mantleDomain: UnsafeMutablePointer<Void>
    var handlers: [Int64: (AnyObject) -> (AnyObject?)] = [:]
    
    var delegate: RiffleDelegate?
    
    
    init(name: String) {
        mantleDomain = NewDomain(name.cString())
        
        super.init()
        delegate = self
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
            
            if let handler = handlers[data[0].longLongValue] {
                // Cuminicate here
                let args = data[1]
                handler(args)
            }
            
            /*
            if let results = handlers[data[0].longLongValue]!(args) {
                let json: [String: AnyObject] = [
                    "id": String(Int64(data["request"] as! Double)),
                    "ok": "",
                    "result": results
                ]

                let out = try! NSJSONSerialization.dataWithJSONObject(json, options: . PrettyPrinted)

                let slice = GoSlice(data: UnsafeMutablePointer<Void>(out.bytes), len: NSNumber(integer: out.length).longLongValue, cap: NSNumber(integer: out.length).longLongValue)
                Yield(slice)
            }
            */
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
    
    
    // MARK: Delegate methods
    func onJoin() { }
    
    func onLeave() { }
}

// Sets itself as the delegate if none provided
@objc public protocol RiffleDelegate {
    func onJoin()
    func onLeave()
}

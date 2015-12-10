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

public class Domain: RiffleDelegate {
    var mantleDomain: UnsafeMutablePointer<Void>
    var handlers: [Int64: (Any) -> (Any?)] = [:]
    
    var delegate: RiffleDelegate?
    
    
    init(name: String) {
        mantleDomain = NewDomain(name.cString())
        delegate = self
    }
    
    public func subscribe(domain: String, fn: (Any) -> ()) {
        let (cb, _) = invocation(Subscribe(mantleDomain, domain.cString()))
        
        handlers[cb] = { (a: Any) -> (Any?) in
            fn(a)
            return nil
        }
    }
    
    public func register(domain: String, fn: (Any) -> (Any?)) {
        let (cb, _) = invocation(Register(mantleDomain, domain.cString()))
        
        handlers[cb] = { (a: Any) -> (Any?) in
            return fn(a)
        }
    }
    func receive() {
        while true {
            let (i, args) = decode(Recieve())
            
            if let handler = handlers[Int64(i)] {
                if let a = args as? Any {
                    //Cuminicate here
                    handler(a)
                } else {
                    print("Unknown args \(args)")
                }
            } else {
                print("No handler found for subscription \(i)")
                print(handlers)
            }
            
//            let s = Recieve()
//            //print("Received: \(s)")
//            let d = NSData(bytes: s.data , length: NSNumber(longLong: s.len).integerValue)
//            let data = try! NSJSONSerialization.JSONObjectWithData(d, options: .AllowFragments) as! [AnyObject]
//            
//            if let handler = handlers[data[0].longLongValue] {
//                // Cuminicate here
//                let args = data[1]
//                handler(args)
//            } else {
//                print("No handler found for subscription \(data[0])")
//                print(handlers)
//            }
            
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
    
    public func join() {
        let (cb, eb) = invocation(Join(mantleDomain))
        
        handlers[cb] = { (a: Any) -> (Any?) in
            if let d = self.delegate {
                d.onJoin()
            }
            
            return nil
        }
        
        handlers[eb] = { (a: Any) -> (Any?) in
            print("Unable to join!")
            return nil
        }
        
        // Kick off the receive thread
        let thread = NSThread(target: self, selector: "receive", object: nil)
        thread.start()
        NSRunLoop.currentRunLoop().run()
    }
    
    
    // MARK: Delegate methods
    public func onJoin() { }
    public func onLeave() { }
}

// Sets itself as the delegate if none provided
public protocol RiffleDelegate {
    func onJoin()
    func onLeave()
}

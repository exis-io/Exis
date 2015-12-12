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
    var handlers: [UInt64: (Any) -> (Any?)] = [:]
    
    var delegate: RiffleDelegate?
    
    
    init(name: String) {
        mantleDomain = NewDomain(name.cString())
        delegate = self
    }
    
    init(name: String, superdomain: Domain) {
        mantleDomain = Subdomain(superdomain.mantleDomain, name.cString())
        delegate = self
    }
    
    public func subscribe(endpoint: String, fn: (Any) -> ()) {
        let cb = CBID()
        Subscribe(self.mantleDomain, cb, endpoint.cString())
        
        handlers[cb] = { (a: Any) -> (Any?) in
            fn(a)
            return nil
        }
    }
    
    public func register(endpoint: String, fn: (Any) -> (Any?)) {
        let cb = CBID()
        Register(self.mantleDomain, cb, endpoint.cString())
        
        handlers[cb] = { (a: Any) -> (Any?) in
            return fn(a)
        }
    }
    
    func receive() {
        while true {
            let (i, args) = decode(Receive(self.mantleDomain))
            
            if let handler = handlers[UInt64(i)] {
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
            
            // TODO: Yield here
            
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
        let cb = CBID()
        let eb = CBID()
        
        Join(mantleDomain, cb, eb)
        
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
//        let thread = NSThread(target: self, selector: "receive", object: nil)
//        thread.start()
//        NSRunLoop.currentRunLoop().run()
        receive()
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

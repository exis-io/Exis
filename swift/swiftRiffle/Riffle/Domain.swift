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
import mantle

#if os(Linux)
//    import mantle
    import SwiftGlibc
    import Glibc
#else
    import Darwin.C
#endif



public protocol Delegate {
    func onJoin()
    func onLeave()
}

public class Domain {
    public var mantleDomain: UnsafeMutablePointer<Void>
    public var delegate: Delegate?
    
    public var handlers: [UInt64: (Any) -> ()] = [:]
    public var invocations: [UInt64: (Any) -> ()] = [:]
    public var registrations: [UInt64: (Any) -> (Any?)] = [:]
    
    
    public init(name: String) {
        mantleDomain = NewDomain(name.cString())
        // delegate = self
    }
    
    public init(name: String, superdomain: Domain) {
        mantleDomain = Subdomain(superdomain.mantleDomain, name.cString())
        // delegate = self
    }
    
    public func subscribe(endpoint: String, fn: (Any) -> ()) {
        let cb = CBID()
        let eb = CBID()
        let hn = CBID()
        
        Subscribe(self.mantleDomain, endpoint.cString(), cb, eb, hn, "[]".cString())
        handlers[hn] = fn
    }
    
    public func register(endpoint: String, fn: (Any) -> (Any?)) {
        let cb = CBID()
        let eb = CBID()
        let hn = CBID()
        
        Register(self.mantleDomain, endpoint.cString(), cb, eb, hn, "[]".cString())
        registrations[hn] = fn
    }
    
    public func publish(endpoint: String, _ args: Any...) {
        let cb = CBID()
        let eb = CBID()
        
        Publish(self.mantleDomain, endpoint.cString(), cb, eb, marshall(args))
    }
    
    public func call(endpoint: String, _ args: Any..., handler: (Any) -> ()) {
        let cb = CBID()
        let eb = CBID()
        
        Call(self.mantleDomain, endpoint.cString(), cb, eb, marshall(args), "[]".cString())
        invocations[cb] = handler
    }
    
    public func receive() {
        while true {
            var (i, args) = decode(Receive(self.mantleDomain))
            
            if let fn = handlers[i] {
                fn(args)
            } else if let fn = invocations[i] {
                fn(args)
            } else if let fn = registrations[i] {
                // Pop off the return arg. Note that we started passing it into crusts as a nested list for some reason. Cant remember why,
                // but retaining that functionality until I remember. It started in the python implementation
                let unwrap = args[0] as! JSON
                var args = unwrap.arrayValue!
                
                let resultId = args.removeAtIndex(0)
                var ret = fn(args)
                ret = ret == nil ? ([] as! [Any]) : ret
                
                //print("Handling return with args: \(ret)")
                Yield(mantleDomain, UInt64(resultId.doubleValue!), marshall(ret))
            } else {
                print("No handlers found for id \(i)!")
            }
        }
    }
    
    public func join() {
        let cb = CBID()
        let eb = CBID()
        
        Join(mantleDomain, cb, eb)
        
        handlers[cb] = { a in
            if let d = self.delegate {
                d.onJoin()
            }
        }
        
        handlers[eb] = { a in
            if let d = self.delegate {
                d.onLeave()
            }
        }
        
        handlers[eb] = { (a: Any) in
            print("Unable to join!")
        }
        
        // Kick off the receive thread
        //let thread = NSThread(target: self, selector: "receive", object: nil)
        //thread.start()
        //NSRunLoop.currentRunLoop().run()
        receive()
    }
    
    
    // MARK: Delegate methods
    public func onJoin() { }
    public func onLeave() { }
}

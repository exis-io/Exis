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
import CoreFoundation
<<<<<<< HEAD:swift/swiftRiffle/Riffle/Domain.swift

#if os(Linux)
    import mantle
=======
import mantle

#if os(Linux)
>>>>>>> origin/arbiter:swift/swiftRiffle/Riffle/Domain.swift
    import SwiftGlibc
    import Glibc
#else
    import Darwin.C
#endif

public protocol Delegate {
    func onJoin()
    func onLeave()
}

<<<<<<< HEAD:swift/swiftRiffle/Riffle/Domain.swift
func serializeArguments(args: [Any]) -> [Any] {
    var ret: [Any] = []
    
    for a in args {
        if let arg = a as? Property {
            ret.append(arg.serialize())
        }
    }
=======
public class Domain {
    public var mantleDomain: UnsafeMutablePointer<Void>
    public var delegate: Delegate?
    
    public var handlers: [UInt64: (Any) -> ()] = [:]
    public var invocations: [UInt64: (Any) -> ()] = [:]
    public var registrations: [UInt64: (Any) -> (Any?)] = [:]
>>>>>>> origin/arbiter:swift/swiftRiffle/Riffle/Domain.swift
    
    return ret
}

public class Domain {
    public var mantleDomain: UnsafeMutablePointer<Void>
    public var delegate: Delegate?
    
    public var handlers: [UInt64: [Any] -> ()] = [:]
    public var invocations: [UInt64: [Any] -> ()] = [:]
    public var registrations: [UInt64: [Any] -> Any?] = [:]
    
<<<<<<< HEAD:swift/swiftRiffle/Riffle/Domain.swift
    
=======
>>>>>>> origin/arbiter:swift/swiftRiffle/Riffle/Domain.swift
    public init(name: String) {
        mantleDomain = NewDomain(name.cString())
        // delegate = self
    }
    
    public init(name: String, superdomain: Domain) {
        mantleDomain = Subdomain(superdomain.mantleDomain, name.cString())
        // delegate = self
    }
    
    public func _subscribe(endpoint: String, fn: [Any] -> ()) {
        let cb = CBID()
        let eb = CBID()
        let hn = CBID() 

        Subscribe(self.mantleDomain, endpoint.cString(), cb, eb, hn, "[]".cString())
        handlers[hn] = fn
    }
    
    public func _register(endpoint: String, fn: [Any] -> Any) {
        let cb = CBID()
        let eb = CBID()
        let hn = CBID() 

        Register(self.mantleDomain, endpoint.cString(), cb, eb, hn, "[]".cString())
        registrations[hn] = fn
    }

    public func publish(endpoint: String, _ args: Any...) {
        let cb = CBID()
        let eb = CBID()
<<<<<<< HEAD:swift/swiftRiffle/Riffle/Domain.swift
        
        Publish(self.mantleDomain, endpoint.cString(), cb, eb, marshall(serializeArguments(args)))
=======

        Publish(self.mantleDomain, endpoint.cString(), cb, eb, marshall(args))
>>>>>>> origin/arbiter:swift/swiftRiffle/Riffle/Domain.swift
    }
    
    public func _call(endpoint: String, _ args: [Any], handler: [Any] -> ()) {
        let cb = CBID()
        let eb = CBID()

<<<<<<< HEAD:swift/swiftRiffle/Riffle/Domain.swift
        Call(self.mantleDomain, endpoint.cString(), cb, eb, marshall(serializeArguments(args)), "[]".cString())
=======
        Call(self.mantleDomain, endpoint.cString(), cb, eb, marshall(args), "[]".cString())
>>>>>>> origin/arbiter:swift/swiftRiffle/Riffle/Domain.swift
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
                var args = args[0] as! [Any]
                let resultId = args.removeAtIndex(0) as! Double
                
<<<<<<< HEAD:swift/swiftRiffle/Riffle/Domain.swift
                // Optional serialization has some problems. This unwraps the result to avoid that particular issue
                if let ret = fn(args) {
                    // TODO: handle tuple returns
                    Yield(mantleDomain, UInt64(resultId), marshall([ret]))
                } else {
                    Yield(mantleDomain, UInt64(resultId), marshall([]))
                }
=======
                let resultId = args.removeAtIndex(0)
                var ret = fn(args)
                ret = ret == nil ? ([] as! [Any]) : ret
>>>>>>> origin/arbiter:swift/swiftRiffle/Riffle/Domain.swift
                
//                var ret = fn(args)
//                print("Function returning with result: \(ret)")
//                
//                let empty: [Any] = []
//                ret = ret == nil ? empty : ret
//                
//                //print("Handling return with args: \(ret)")
//                Yield(mantleDomain, UInt64(resultId), marshall(ret))
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
            } else {
                self.onJoin()
            }
        }

        handlers[eb] = { a in
            if let d = self.delegate {
                d.onLeave()
            } else {
                self.onLeave()
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
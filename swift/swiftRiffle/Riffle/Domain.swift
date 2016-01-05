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

#if os(Linux)
    import mantle
    import SwiftGlibc
    import Glibc
#else
    import Darwin.C
#endif

public protocol Delegate {
    func onJoin()
    func onLeave()
}

func serializeArguments(args: [Any]) -> [Any] {
    var ret: [Any] = []
    
    for a in args {
        if let arg = a as? Property {
            ret.append(arg.serialize())
        }
    }
    
    return ret
}

// Just here for testing right now, will end up in Cumin
public extension Domain {
    public func call<A: PR>(endpoint: String, _ callArguments: Any..., _ fn: (A) -> ()) -> Deferred {
        return _call(endpoint, callArguments) { args in
            fn(A.deserialize(args[0]) as! A)
        }
    }
}

public class Domain {
    public var mantleDomain: UnsafeMutablePointer<Void>
    public var delegate: Delegate?
    
    public var invocations: [UInt64: [Any] -> ()] = [:]
    public var registrations: [UInt64: [Any] -> Any?] = [:]
    
    var deferreds: [UInt64: Deferred] = [:]
    var handlers: [UInt64: [Any] -> ()] = [:]
    
    public init(name: String) {
        mantleDomain = NewDomain(name.cString())
    }
    
    public init(name: String, superdomain: Domain) {
        mantleDomain = Subdomain(superdomain.mantleDomain, name.cString())
    }
    
    public func _subscribe(endpoint: String, fn: [Any] -> ()) -> Deferred {
        let hn = CBID()
        handlers[hn] = fn
        
        let d = Deferred(domain: self)
        Subscribe(self.mantleDomain, endpoint.cString(), d.cb, d.eb, hn, "[]".cString())
        return d
    }
    
    public func _register(endpoint: String, fn: [Any] -> Any) -> Deferred {
        let hn = CBID()
        registrations[hn] = fn

        let d = Deferred(domain: self)
        Register(self.mantleDomain, endpoint.cString(), d.cb, d.eb, hn, "[]".cString())
        return Deferred()
    }

    public func publish(endpoint: String, _ args: Any...) -> Deferred {
        let d = Deferred(domain: self)
        Publish(self.mantleDomain, endpoint.cString(), d.cb, d.eb, marshall(serializeArguments(args)))
        return Deferred()
    }
    
    public func _call(endpoint: String, _ args: [Any], handler: [Any] -> ()) -> Deferred {
        let d = Deferred(domain: self)
        Call(self.mantleDomain, endpoint.cString(), d.cb, d.eb, marshall(serializeArguments(args)), "[]".cString())
        return Deferred()
    }
    
    public func receive() {
        while true {
            var (i, args) = decode(Receive(self.mantleDomain))
            print("Receive loop has args: ", args)
            if let fn = handlers[i] {
                fn(args)
            } else if let fn = invocations[i] {
                fn(args)
            } else if let fn = registrations[i] {
                let resultId = args.removeAtIndex(0) as! Double
                
                // Optional serialization has some problems. This unwraps the result to avoid that particular issue
                if let ret = fn(args) {
                    // TODO: handle tuple returns
                    Yield(mantleDomain, UInt64(resultId), marshall([ret]))
                } else {
                    Yield(mantleDomain, UInt64(resultId), marshall([]))
                }
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
        
        handlers[eb] = { (a: Any) in
            print("Unable to join!")
        }
        
        receive()
    }
    
    
    // MARK: Delegate methods
    public func onJoin() { }
    public func onLeave() { }
}
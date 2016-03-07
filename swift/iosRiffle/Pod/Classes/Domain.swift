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
import Mantle

public protocol Delegate {
    func onJoin()
    func onLeave()
}


public class Domain {
    public var delegate: Delegate?
    var mantleDomain: MantleDomain
    var app: App
    
    
    public init(name: String) {
        mantleDomain = MantleNewDomain(name)
        app = App(domain: mantleDomain)
    }
    
    public init(name: String, superdomain: Domain) {
        mantleDomain = superdomain.mantleDomain.subdomain(name)
        app = superdomain.app
    }
    
    public func _subscribe(endpoint: String, _ types: [Any], fn: [Any] -> ()) -> Deferred {
        let hn = CBID()
        app.handlers[hn] = fn

        let d = Deferred(domain: self)
//        mantleDomain.subscribe(endpoint, d.cb, d.eb, hn, marshall(serializeArguments(types)))
        return d
    }
    
    public func _register(endpoint: String, _ types: [Any], fn: [Any] -> Any) -> Deferred {
        let hn = CBID()
        app.registrations[hn] = fn

        let d = Deferred(domain: self)
//        mantleDomain.register(endpoint, d.cb, d.eb, hn, marshall(types))
        return d
    }

    public func publish(endpoint: String, _ args: Any...) -> Deferred {
        let d = Deferred(domain: self)
        mantleDomain.publish(endpoint, cb: String(d.cb), eb: String(d.eb), args: marshall(serializeArguments(args)))
        return d
    }
//
    public func call(endpoint: String, _ args: Any...) -> HandlerDeferred {
        let d = HandlerDeferred(domain: self)
        d.mantleDomain = self.mantleDomain
//        mantleDomain.call(endpoint, d.cb, d.eb, marshall(serializeArguments(args)))
        return d
    }
    
    public func join() {
        let cb = CBID()
        let eb = CBID()
        
        mantleDomain.join(String(cb), eb: String(eb))
        
        app.handlers[cb] = { a in
            if let d = self.delegate {
                d.onJoin()
            } else {
                self.onJoin()
            }
        }

        app.handlers[eb] = { a in
            if let d = self.delegate {
                d.onLeave()
            } else {
                self.onLeave()
            }
        }
        
        app.handlers[eb] = { (a: Any) in
            print("Unable to join!")
        }
        
        app.receive()
    }
    
    
    // MARK: Delegate methods
    public func onJoin() { }
    public func onLeave() { }
}



class App {
    var mantleDomain: MantleDomain
    
    var deferreds: [Double: Deferred] = [:]
    var handlers: [Double: [Any] -> ()] = [:]
    var registrations: [Double: [Any] -> Any?] = [:]


    init(domain: MantleDomain) {
        mantleDomain = domain
    }
    
    func receive() {
        while true {
            var (i, args) = decode(mantleDomain.receive())
            
            if let d = deferreds[i] {
                // remove the deferred (should this ever be optional?)
                deferreds[d.cb] = nil
                deferreds[d.eb] = nil
                
                if d.cb == i {
                    d.callback(args)
                }
                
                if d.eb == i {
                    d.errback(args)
                }
            } else if let fn = handlers[i] {
                fn(args)
            } else if let fn = registrations[i] {
                let resultId = args.removeAtIndex(0) as! Double
                
                // Optional serialization has some problems. This unwraps the result to avoid that particular issue
//                if let ret = fn(args) {
//                    // Function did not return anything
//                    if let _ = ret as? Void {
//                        Yield(mantleDomain, UInt64(resultId), marshall([]))
//                        
//                    // If function returned an array it could be a tuple
//                    } else {
//                        Yield(mantleDomain, UInt64(resultId), marshall([ret]))
//                    }
//                } else {
//                    let empty: [Any] = []
//                    Yield(mantleDomain, UInt64(resultId), marshall(empty))
//                }
            }
        }
    }
}
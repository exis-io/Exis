//
//  main.swift
//  RiffleTest
//
//  Created by Mickey Barboi on 11/22/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation
import CoreFoundation
import Mantle


#if os(Linux)
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
    public var delegate: Delegate?
    var mantleDomain: UInt64
    var app: App
    
    
    public init(name: String) {
        mantleDomain = NewDomain(name.cString())
        app = App(domain: mantleDomain)
    }
    
    public init(name: String, superdomain: Domain) {
        mantleDomain = Subdomain(superdomain.mantleDomain, name.cString())
        app = superdomain.app
    }
    
    public func _subscribe(endpoint: String, _ types: [Any], fn: [Any] -> ()) -> Deferred {
        let hn = CBID()
        app.handlers[hn] = fn

        let d = Deferred(domain: self)
        Subscribe(self.mantleDomain, endpoint.cString(), d.cb, d.eb, hn, marshall(serializeArguments(types)))
        return d
    }
    
    public func _register(endpoint: String, _ types: [Any], fn: [Any] -> Any) -> Deferred {
        let hn = CBID()
        app.registrations[hn] = fn

        let d = Deferred(domain: self)
        Register(self.mantleDomain, endpoint.cString(), d.cb, d.eb, hn, marshall(types))
        return d
    }

    public func publish(endpoint: String, _ args: Any...) -> Deferred {
        let d = Deferred(domain: self)
        Publish(self.mantleDomain, endpoint.cString(), d.cb, d.eb, marshall(serializeArguments(args)))
        return d
    }
    
    public func call(endpoint: String, _ args: Any...) -> HandlerDeferred {
        let d = HandlerDeferred(domain: self)
        d.mantleDomain = self.mantleDomain
        Call(self.mantleDomain, endpoint.cString(), d.cb, d.eb, marshall(serializeArguments(args)))
        return d
    }
    
    public func join() {
        
        let cb = CBID()
        let eb = CBID()
        
        Join(mantleDomain, cb, eb)
        
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
        
        // Differences based on implementation differences in open source swift and apple swift
        #if os(Linux)
            self.app.receive()
        #else
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                self.app.receive()
            }
        #endif       
        
    }
    
    
    // MARK: Delegate methods
    public func onJoin() { }
    public func onLeave() { }
}


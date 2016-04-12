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

// For testing initial initial implementation of model objects, not a permanent fixture
var globalConnectionReference: Domain?

public class Domain {
    public var delegate: Delegate?
    var mantleDomain: UInt64
    var app: App
    
    
    public init(name: String) {
        mantleDomain = NewDomain(name.cString())
        app = App(domain: mantleDomain)
        globalConnectionReference = self
    }
    
    public init(name: String, superdomain: Domain) {
        mantleDomain = Subdomain(superdomain.mantleDomain, name.cString())
        app = superdomain.app
    }
    
    public func _subscribe(endpoint: String, _ types: [Any], fn: [Any] -> ()) -> Deferred {
        let hn = CBID()
        let d = Deferred(domain: self)
        
        app.handlers[hn] = fn
        Subscribe(self.mantleDomain, endpoint.cString(), d.cb, d.eb, hn, marshall(serializeArguments(types)))
        return d
    }
    
    public func _register(endpoint: String, _ types: [Any], fn: [Any] -> Any) -> Deferred {
        let hn = CBID()
        let d = Deferred(domain: self)
        
        app.registrations[hn] = fn
        Register(self.mantleDomain, endpoint.cString(), d.cb, d.eb, hn, marshall(types))
        return d
    }
    
    public func publish(endpoint: String, _ args: Property...) -> Deferred {
        let d = Deferred(domain: self)
        Publish(self.mantleDomain, endpoint.cString(), d.cb, d.eb, marshall(serializeArguments(args)))
        return d
    }
    
    public func call(endpoint: String, _ args: Property...) -> HandlerDeferred {
        let d = HandlerDeferred(domain: self)
        Call(self.mantleDomain, endpoint.cString(), d.cb, d.eb, marshall(serializeArguments(args)))
        return d
    }
    
    public func leave() {
        Leave(self.mantleDomain)
    }
    
    public func setToken(token: String) {
        SetToken(self.mantleDomain, token.cString())
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
        
        app.handlers[eb] = { (a: Any) in
            print("Unable to join: \(a)")
        }
        
        // Implementation differences in open source swift and apple swift. Should come together soon
        // based on swift 2.2 Grand Central Dispatch progress
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
    
    // MARK: Temporary methods, going to move to AppDomain
    public func register() {
        
    }
    
    public func login() {
        
    }
}

/*
 The Auth api
 
 // Represents the connection in addition to the domain itself
 app = AppDomain(name: "xs.test")
 you = Domain(name: "alpha", superdomain: app)
 
 // myName comes back as a string
 // join checks persistence for a token then presents it to the fabric. Fails if the
 // token can't be found or the fabric rejects the token
 app.join().then { myName: String
 let me = Domain(myDomain, superdomain: app)
 
 // Blocks and runs the reactor loop
 app.listen()
 
 }.error {
 // Username and password is obtained from some input source-- ui, cli prompt, etc
 let username = "someUsernameFromInput"
 let password = "somePasswordFromInput"
 
 // Attempt to obtain a token to auth on the fabric. Returns the name of this domain
 // If the login  succeeded the token is persisted under the name presented when the
 // login request was started
 app.login("sender", username, password).then { myName: String
 me= Domain(myDomain, superdomain: app)
 app.listen()
 
 // Returns whatever error the Auth appliance returned as a string
 }.error { reason: String
 print("reason: \(reason)") // Waiting on email...
 }
 
 // Attempt to register with the given credentials.
 // If the login  succeeded the token is persisted under the name presented when the
 // login request was started
 app.register("sender", username, password).then { myDomain in
 me = Domain(myDomain, superdomain: app)
 app.listen()
 
 }.error { reason in
 print(reason) // Username taken, password too short
 }
 }
 */

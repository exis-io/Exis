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
    var delegate: RiffleDelegate?
    
    var handlers: [UInt64: (Any) -> ()] = [:]
    var invocations: [UInt64: (Any) -> ()] = [:]
    var registrations: [UInt64: (Any) -> (Any?)] = [:]
    
    
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
        handlers[cb] = fn
    }
    
    public func register(endpoint: String, fn: (Any) -> (Any?)) {
        let cb = CBID()
        Register(self.mantleDomain, cb, endpoint.cString())
        registrations[cb] = fn
    }
    
    public func call(endpoint: String, args: AnyObject..., handler: (Any) -> ()) {
        let cb = CBID()
        Call(self.mantleDomain, cb, endpoint.cString(), marshall(args))
        invocations[cb] = handler
    }
    
    public func publish(endpoint: String, args: AnyObject...) {
        let marshalled = marshall(args)
        print("Publishing: \(endpoint) with args \(args) marshalled: \(marshalled)")
        Publish(self.mantleDomain, 0, endpoint.cString(), marshalled)
    }
    
    func receive() {
        while true {
            let (i, args) = decode(Receive(self.mantleDomain))
            
            if let fn = handlers[i] {
                fn(args)
            } else if let fn = invocations[i] {
                fn(args)
            } else if let fn = registrations[i] {
                if let ret = fn(args) {
                    print("Handling return with args: \(ret)")
                } else {
                    print("Not handling returns!")
                }
            } else {
                print("No handlers found for id \(i)")
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
        
        handlers[eb] = { (a: Any) in
            print("Unable to join!")
        }
        
        // Kick off the receive thread
        let thread = NSThread(target: self, selector: "receive", object: nil)
        thread.start()
        NSRunLoop.currentRunLoop().run()
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

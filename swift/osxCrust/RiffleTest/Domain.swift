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
    
    public func call(endpoint: String, args: AnyObject...) {
        let cb = CBID()
        
        
        
//        Call(self.mantleDomain, cb, endpoint.cString(), )
    }
    
    func receive() {
        while true {
            let (i, args) = decode(Receive(self.mantleDomain))
            
            if let handler = handlers[UInt64(i)] {
                if let a = args as? Any {
                    
                    //Cuminicate here
                    if let ret = handler(a) {
                        // If ret then we have a return value
                    }
                } else {
                    print("Unknown args \(args)")
                }
            } else {
                print("No handler found for subscription \(i)")
                print(handlers)
            }
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

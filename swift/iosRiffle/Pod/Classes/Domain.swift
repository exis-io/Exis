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


/* The linker is *very* unhappy with exported references that themselves have references to Mantle objects
 In other words, we can't have them in the Domain object.

     var mantleDomain: MantleDomain

 in this class. The references have to be indirect, either through some access bus
 or another object that runs interference.

 Things that dont work:
      Subclassing MantleDomain
      Making the ivar private

This data structure and set of accessors manage access to an array that indexes the MantleDomains.
If you're still reading this, then the current implementation is primitive.
*/
class DomainIndex {
    private static var currentIndex = 0
    private static var mantleDomainIndex: [MantleDomain] = []
    
    class func get(i: Int) -> MantleDomain {
        return mantleDomainIndex[i]
    }
    
    class func set(domain: MantleDomain) -> Int {
        mantleDomainIndex.append(domain)
        return mantleDomainIndex.count - 1
    }
}


public class Domain {
    public var delegate: Delegate?
    var app: App
    var domainIndex = 0
    
    public init(name: String) {
//        mantleDomain = MantleNewDomain(name)
//        app = App(domain: mantleDomain)
        
        let domain = MantleNewDomain(name)
        domainIndex = DomainIndex.set(domain)
        app = App(domain: domain)
    }
    
    public init(name: String, superdomain: Domain) {
//        mantleDomain = superdomain.mantleDomain.subdomain(name)
//        app = superdomain.app
        
        let domain = DomainIndex.get(superdomain.domainIndex).subdomain(name)
        domainIndex = DomainIndex.set(domain)
        app = App(domain: domain)
    }
    
    public func _subscribe(endpoint: String, _ types: [Any], fn: [Any] -> ()) -> Deferred {
        let hn = CBID()
        app.handlers[hn] = fn

        let d = Deferred(domain: self)
        print("\(endpoint) subbed with: \(hn) (converted: \(hn.go()))")
        DomainIndex.get(domainIndex).subscribe(endpoint, cb: d.cb.go(), eb: d.eb.go(), fn: hn.go(), types: marshall(serializeArguments(types)))
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
//        mantleDomain.publish(endpoint, cb: String(d.cb), eb: String(d.eb), args: marshall(serializeArguments(args)))
        DomainIndex.get(domainIndex).publish(endpoint, cb: d.cb.go(), eb: d.eb.go(), args: marshall(serializeArguments(args)))
        return d
    }
//
    public func call(endpoint: String, _ args: Any...) -> HandlerDeferred {
        let d = HandlerDeferred(domain: self)
//        d.mantleDomain = self.mantleDomain
//        mantleDomain.call(endpoint, d.cb, d.eb, marshall(serializeArguments(args)))
        return d
    }
    
    public func join() {
        let cb = CBID()
        let eb = CBID()
        
//        mantleDomain.join(String(cb), eb: String(eb))
    
        DomainIndex.get(domainIndex).join(cb.go(), eb: eb.go())
        
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
        
        // Very different in swift 2.2, since we may still not have access to GCD
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.app.receive()
        }
    }
    
    
    // MARK: Delegate methods
    public func onJoin() { }
    public func onLeave() { }
}


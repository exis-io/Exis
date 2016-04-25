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


public protocol DomainDelegate {
    func onJoin()
    func onLeave()
}


public class Domain: CoreClass {
    public var delegate: DomainDelegate?
    public private(set) var name: String
    
    var app: CoreApp
    
    
    init(name: String, app: CoreApp) {
        self.name = name
        self.app = app
        super.init()
        
        let (join, leave) = assignDeletegateHandlers()

        sendCore("NewDomain", address: address, object: app.address, args: [name, join, leave], synchronous: true)
    }
    
    public init(name: String, superdomain: Domain) {
        app = superdomain.app
        self.name = "\(superdomain.name).\(name)"
        super.init()
        
        let (join, leave) = assignDeletegateHandlers()
        sendCore("Subdomain", address: address, object: superdomain.address, args: [name, join, leave], synchronous: true)
    }
    
    func _subscribe(endpoint: String, _ types: [Any], options: Options, fn: [Any] -> ()) -> Deferred {
        let hn = DomainHandler() { a in fn(a) }
        return callCore("Subscribe", args: [endpoint, hn.id, types, options.marshall()])
    }
    
    func _register(endpoint: String, _ types: [Any], options: Options, fn: [Any] -> [Any]) -> Deferred {
        let hn = DomainHandler() { a in
            var args = a
            let resultId = args.removeAtIndex(0) as! Double
            let yieldOptions: [String: Any] = [:]
            self.app.callCore("Yield", args: [resultId, fn(args), yieldOptions])
        }
        
        return callCore("Register", args: [endpoint, hn.id, types, options.marshall()])
    }
    
    public func publish(endpoint: String, _ args: Property...) -> Deferred {
        return callCore("Publish", args: [endpoint, serializeArguments(args), Options().marshall()])
    }
    
    public func call(endpoint: String, _ args: Property...) -> HandlerDeferred {
        let d = HandlerDeferred()
        d.domain = self
        
        callCore("Call", deferred: d, args: [endpoint, serializeArguments(args), Options().marshall()])
        return d
    }
    
    public func leave() {
        callCore("Leave", args: [])
    }
    
    public func join() -> Deferred {
        return callCore("Join", args: [])
    }
    
    // Creates a pair of delegate handlers and registers them with the session
    func assignDeletegateHandlers() -> (UInt64, UInt64) {
        let join = DomainHandler() { a in
            self.onJoin()
            
            if let delegate = self.delegate {
                delegate.onJoin()
            }
        }
        
        let leave = DomainHandler() { a in
            self.onLeave()
            
            if let delegate = self.delegate {
                delegate.onLeave()
            }
        }
        
        return (join.id, leave.id)
    }
    
    
    // MARK: Delegate methods
    public func onJoin() { }
    public func onLeave() { }
}

extension Domain: Equatable {}

public func ==(lhs: Domain, rhs: Domain) -> Bool {
    return lhs.name == rhs.name
}


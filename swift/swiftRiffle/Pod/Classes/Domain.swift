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

        sendCore("NewDomain", handler: address, address: app.address, [name, join, leave])
    }
    
    public init(name: String, superdomain: Domain) {
        app = superdomain.app
        self.name = "\(superdomain.name).\(name)"
        super.init()
        
        let (join, leave) = assignDeletegateHandlers()
        sendCore("Subdomain", handler: address, address: superdomain.address, [name, join, leave])
    }
    
    func _subscribe(endpoint: String, _ types: [Any], options: Options, fn: [Any] -> ()) -> Deferred {
        let hn = DomainHandler() { a in fn(a) }
        return callCore("Subscribe", [endpoint, hn.id, types, options.marshall()])
    }
    
    func _register(endpoint: String, _ types: [Any], options: Options, fn: [Any] -> [Any]) -> Deferred {
        let hn = DomainHandler() { a in
            var args = a
            let resultId = args.removeAtIndex(0) as! Double
            self.app.callCore("Yield", [UInt64(resultId), serializeArguments(fn(args))])
        }
        
        return callCore("Register", [endpoint, hn.id, types, options.marshall()])
    }
    
    public func publish(endpoint: String, _ args: Property...) -> Deferred {
        return callCore("Publish", [endpoint, serializeArguments(args), Options().marshall()])
    }
    
    public func call(endpoint: String, _ args: Property...) -> HandlerDeferred {
        let d = HandlerDeferred()
        callCore("Call", deferred: d, [endpoint, serializeArguments(args), Options().marshall()])
        return d
    }
    
    public func leave() {
        callCore("Leave", [])
    }
    
    public func join() -> Deferred {
        return callCore("Join", [])
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


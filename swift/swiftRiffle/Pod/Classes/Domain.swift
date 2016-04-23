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
        // initCore("Domain", [name])

        sendCore("NewDomain", handler: address, address: app.address, [name])
    }
    
    public init(name: String, superdomain: Domain) {
        app = superdomain.app
        self.name = "\(superdomain.name).\(name)"
        //mantleDomain = Subdomain(superdomain.mantleDomain, name.cString())
    }
    
    func _subscribe(endpoint: String, _ types: [Any], options: Options, fn: [Any] -> ()) -> Deferred {
        let hn = DomainHandler() { a in fn(a) }
        return callCore("Subscribe", [endpoint, hn.id, types, options.marshall()])
        
        // Subscribe(self.mantleDomain, endpoint.cString(), d.cb, d.eb, hn, marshall(serializeArguments(types)), options.marshall())
    }
    
    func _register(endpoint: String, _ types: [Any], options: Options, fn: [Any] -> [Any]) -> Deferred {
        let hn = DomainHandler() { a in
            var args = a
            let resultId = args.removeAtIndex(0) as! Double
            self.app.callCore("Yield", [UInt64(resultId), marshall(fn(args))])
        }
        
        return callCore("Register", [endpoint, hn.id, types, options.marshall()])
        //Register(self.mantleDomain, endpoint.cString(), d.cb, d.eb, hn, marshall(types), options.marshall())
    }
    
    public func publish(endpoint: String, _ args: Property...) -> Deferred {
        //Publish(self.mantleDomain, endpoint.cString(), d.cb, d.eb, marshall(serializeArguments(args)), Options().marshall())
        return callCore("Publish", [endpoint, args])
    }
    
    public func call(endpoint: String, _ args: Property...) -> HandlerDeferred {
        let d = HandlerDeferred()
        //Call(self.mantleDomain, endpoint.cString(), d.cb, d.eb, marshall(serializeArguments(args)), Options().marshall())
        callCore("Call", deferred: d, [endpoint, args])
        return d
    }
    
    public func leave() {
        callCore("Leave", [])
    }
    
    public func join() -> Deferred {
        // Should turn join into a handler method and register onJoin and onLeave, i think
        // We don't really want a deferred here with the new Auth API
        return callCore("Join", [])
        
        //Join(mantleDomain, cb, eb)
        
//        app.handlers[cb] = { a in
//            if let d = self.delegate {
//                d.onJoin()
//            } else {
//                self.onJoin()
//            }
//        }
        
//        app.handlers[eb] = { (a: Any) in
//            print("Unable to join: \(a)")
//        }
//        
//        // Implementation differences in open source swift and apple swift. Should come together soon
//        // based on swift 2.2 Grand Central Dispatch progress
//        #if os(Linux)
//            self.app.receive()
//        #else
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//                self.app.receive()
//            }
//        #endif
    }
    
    
    // MARK: Delegate methods
    public func onJoin() { }
    public func onLeave() { }
}

extension Domain: Equatable {}

public func ==(lhs: Domain, rhs: Domain) -> Bool {
    return lhs.name == rhs.name
}


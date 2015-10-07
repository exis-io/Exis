//
//  Riffle.swift
//  Pods
//
//  Created by Mickey Barboi on 9/25/15.
//
//

import Foundation

var NODE = ""

// Sets itself as the delegate if none provided
@objc public protocol RiffleDelegate {
    func onJoin()
    func onLeave()
}


// Seting URL-- Better to use a singleton.
public func setFabric(url: String) {
    NODE = url
}

public class RiffleSession: NSObject, MDWampClientDelegate, RiffleDelegate {
    var socket: MDWampTransportWebSocket
    var session: MDWamp
    public var domain: String
    
    public var delegate: RiffleDelegate?
    
    
    public init(domain d: String) {
        socket = MDWampTransportWebSocket(server:NSURL(string: NODE), protocolVersions:[kMDWampProtocolWamp2msgpack, kMDWampProtocolWamp2json])
        domain = d
        // Oh, the hacks you'll see
        session = MDWamp()
        super.init()
        
        session = MDWamp(transport: socket, realm: domain, delegate: self)
    }
    
    public func connect() {
        if delegate == nil {
            delegate = self
        }
        
        session.connect()
    }
    
    public func handle(args: AnyObject...) {
        
    }

    
    //MARK: Delegates
    public func mdwamp(wamp: MDWamp!, sessionEstablished info: [NSObject : AnyObject]!) {
        print("Session Established!")
        delegate!.onJoin()
    }
    
    public func mdwamp(wamp: MDWamp!, closedSession code: Int, reason: String!, details: [NSObject : AnyObject]!) {
        print("Session Closed!")
        delegate!.onLeave()
    }
    
    public func onJoin() {
        // Called when a session closes. Setup here.
    }
    
    public func onLeave() {
        // called when a session closes. Do any cleanup here
    }
    
    
    // MARK: Real Calls
    func _subscribe(endpoint: String, fn: ([AnyObject]) -> ()) {
        // This is the real subscrive method
        session.subscribe(endpoint, onEvent: { (event: MDWampEvent!) -> Void in
            // Trigger the callback
            fn(event.arguments)
            
            }) { (err: NSError!) -> Void in
                if let e = err {
                    print("An error occured: ", e)
                }
        }
    }
    
    func _register(endpoint: String, fn: ([AnyObject]) -> ()) {
        session.registerRPC(endpoint, procedure: { (wamp: MDWamp!, invocation: MDWampInvocation!) -> Void in
            
            fn(invocation.arguments)
            wamp.resultForInvocation(invocation, arguments: [], argumentsKw: [:])
            
            }, cancelHandler: { () -> Void in
                print("Register Cancelled!")
            }) { (err: NSError!) -> Void in
                //print("Registration completed: \(endpoint)")
        }
    }
    
    func _register<R: AnyObject>(endpoint: String, fn: ([AnyObject]) -> (R)) {
        session.registerRPC(endpoint, procedure: { (wamp: MDWamp!, invocation: MDWampInvocation!) -> Void in
            
            let result = fn(invocation.arguments)
            wamp.resultForInvocation(invocation, arguments: [result], argumentsKw: [:])
            
            }, cancelHandler: { () -> Void in
                print("Register Cancelled!")
            }) { (err: NSError!) -> Void in
                //print("Registration completed: \(endpoint)")
        }
    }
    
    
    //MARK: OLD CODE
    public func call(endpoint: String, _ args: AnyObject..., handler: (([AnyObject]) -> ())?) {
        session.call(endpoint, payload: args) { (result: MDWampResult!, err: NSError!) -> Void in
            if err != nil {
                print("Call Error for endpoint \(endpoint): \(err)")
            }
            else {
                if let h = handler {
                    h(result.arguments == nil ? [] : result.arguments)
                }
            }
        }
    }
    
    public func publish(endpoint: String, _ args: AnyObject...) {
        session.publishTo(endpoint, args: args, kw: [:], options: [:]) { (err: NSError!) -> Void in
            if let e = err {
                print("Error: ", e)
                print("Publish Error for endpoint \"\(endpoint)\": \(e)")
            }
        }
    }
    
    
    //MARK: Messaging Patterns with a dash of Cumin
    public func register(domain: String, _ fn: () -> ())  {
        _register(domain, fn: cumin(fn))
    }
    
    public func register<A>(domain: String, _ fn: (A) -> ())  {
        _register(domain, fn: cumin(fn))
    }
    
    public func register<A, B>(domain: String, _ fn: (A, B) -> ())  {
        _register(domain, fn: cumin(fn))
    }
    
    public func register<A, B, C>(domain: String, _ fn: (A, B, C) -> ())  {
        _register(domain, fn: cumin(fn))
    }
    
    public func register<R: AnyObject>(domain: String, _ fn: () -> (R))  {
        _register(domain, fn: cumin(fn))
    }
    
    public func register<A, R: AnyObject>(domain: String, _ fn: (A) -> (R))  {
        _register(domain, fn: cumin(fn))
    }
    
    public func register<A, B, R: AnyObject>(domain: String, _ fn: (A, B) -> (R))  {
        _register(domain, fn: cumin(fn))
    }
    
    public func register<A, B, C, R: AnyObject>(domain: String, _ fn: (A, B, C) -> (R))  {
        _register(domain, fn: cumin(fn))
    }
    
    public func subscribe(domain: String, _ fn: () -> ())  {
        _subscribe(domain, fn: cumin(fn))
    }
    
    public func subscribe<A>(domain: String, _ fn: (A) -> ())  {
        _subscribe(domain, fn: cumin(fn))
    }
    
    public func subscribe<A, B>(domain: String, _ fn: (A, B) -> ())  {
        _subscribe(domain, fn: cumin(fn))
    }
    
    public func subscribe<A, B, C>(domain: String, _ fn: (A, B, C) -> ())  {
        _subscribe(domain, fn: cumin(fn))
    }
}

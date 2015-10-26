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
        print("Session Closed. Code: \(code), reason: \(reason), details: \(details)")
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
            print(event.arguments)
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
    
    func _register<R>(endpoint: String, fn: ([AnyObject]) -> (R)) {
        session.registerRPC(endpoint, procedure: { (wamp: MDWamp!, invocation: MDWampInvocation!) -> Void in
            
            let result = fn(invocation.arguments)
            if let autoArray = result as? [AnyObject] {
                wamp.resultForInvocation(invocation, arguments: autoArray, argumentsKw: [:])
            } else {
                wamp.resultForInvocation(invocation, arguments: [result as! AnyObject], argumentsKw: [:])
            }
            
            }, cancelHandler: { () -> Void in
                print("Register Cancelled!")
            }) { (err: NSError!) -> Void in
                //print("Registration completed: \(endpoint)")
        }
    }
    
    func _call(endpoint: String, args: [AnyObject], fn: (([AnyObject]) -> ())?) {
        // The caller received the result of the call from the callee
        
        session.call(endpoint, payload: serialize(args)) { (result: MDWampResult!, err: NSError!) -> Void in
            if err != nil {
                print("Call Error for endpoint \(endpoint): \(err)")
            }
            else {
                if let h = fn {
                    h(result.arguments == nil ? [] : result.arguments)
                }
            }
        }
    }
    
    public func publish(endpoint: String, _ args: AnyObject...) {
        session.publishTo(endpoint, args: serialize(args), kw: [:], options: [:]) { (err: NSError!) -> Void in
            if let e = err {
                print("Error: ", e)
                print("Publish Error for endpoint \"\(endpoint)\": \(e)")
            }
        }
    }
    
    public func unregister(endpoint: String) {
        session.unregisterRPC(endpoint, result: nil)
    }
    
    public func unsubscribe(endpoint: String) {
        session.unsubscribe(endpoint, result: nil)
    }
    
    
    //MARK: Cumin Wrappers
    // Thses are all boilerplate. Ignore them.
    public func register(pdid: String, _ fn: () -> ())  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A>(pdid: String, _ fn: (A) -> ())  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B>(pdid: String, _ fn: (A, B) -> ())  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, C>(pdid: String, _ fn: (A, B, C) -> ())  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, C, D>(pdid: String, _ fn: (A, B, C, D) -> ())  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, C, D, E>(pdid: String, _ fn: (A, B, C, D, E) -> ())  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<R>(pdid: String, _ fn: () -> (R))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, R>(pdid: String, _ fn: (A) -> (R))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, R>(pdid: String, _ fn: (A, B) -> (R))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, C, R>(pdid: String, _ fn: (A, B, C) -> (R))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, C, D, R>(pdid: String, _ fn: (A, B, C, D) -> (R))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, C, D, E, R>(pdid: String, _ fn: (A, B, C, D, E) -> (R))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<R, S>(pdid: String, _ fn: () -> (R, S))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, R, S>(pdid: String, _ fn: (A) -> (R, S))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, R, S>(pdid: String, _ fn: (A, B) -> (R, S))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, C, R, S>(pdid: String, _ fn: (A, B, C) -> (R, S))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, C, D, R, S>(pdid: String, _ fn: (A, B, C, D) -> (R, S))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, C, D, E, R, S>(pdid: String, _ fn: (A, B, C, D, E) -> (R, S))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<R, S, T>(pdid: String, _ fn: () -> (R, S, T))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, R, S, T>(pdid: String, _ fn: (A) -> (R, S, T))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, R, S, T>(pdid: String, _ fn: (A, B) -> (R, S, T))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, C, R, S, T>(pdid: String, _ fn: (A, B, C) -> (R, S, T))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, C, D, R, S, T>(pdid: String, _ fn: (A, B, C, D) -> (R, S, T))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func register<A, B, C, D, E, R, S, T>(pdid: String, _ fn: (A, B, C, D, E) -> (R, S, T))  {
        _register(pdid, fn: cumin(fn))
    }
    
    public func subscribe(pdid: String, _ fn: () -> ())  {
        _subscribe(pdid, fn: cumin(fn))
    }
    
    public func subscribe<A>(pdid: String, _ fn: (A) -> ())  {
        _subscribe(pdid, fn: cumin(fn))
    }
    
    public func subscribe<A, B>(pdid: String, _ fn: (A, B) -> ())  {
        _subscribe(pdid, fn: cumin(fn))
    }
    
    public func subscribe<A, B, C>(pdid: String, _ fn: (A, B, C) -> ())  {
        _subscribe(pdid, fn: cumin(fn))
    }
    
    public func subscribe<A, B, C, D>(pdid: String, _ fn: (A, B, C, D) -> ())  {
        _subscribe(pdid, fn: cumin(fn))
    }
    
    public func subscribe<A, B, C, D, E>(pdid: String, _ fn: (A, B, C, D, E) -> ())  {
        _subscribe(pdid, fn: cumin(fn))
    }
    
    public func call(pdid: String, _ args: AnyObject..., handler fn: (() -> ())?)  {
        _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
    }
    
    public func call<A>(pdid: String, _ args: AnyObject..., handler fn: ((A) -> ())?)  {
        _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
    }
    
    public func call<A, B>(pdid: String, _ args: AnyObject..., handler fn: ((A, B) -> ())?)  {
        _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
    }
    
    public func call<A, B, C>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C) -> ())?)  {
        _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
    }
    
    public func call<A, B, C, D>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D) -> ())?)  {
        _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
    }
    
    public func call<A, B, C, D, E>(pdid: String, _ args: AnyObject..., handler fn: ((A, B, C, D, E) -> ())?)  {
        _call(pdid, args: args, fn: fn == nil ? nil: cumin(fn!))
    }
    
}

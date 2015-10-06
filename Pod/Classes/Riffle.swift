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
    
    public func stuffy() -> String {
        return stuff()
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
    
    
    //MARK: Utility
    func extractArgs(args: [AnyObject]) -> [AnyObject] {
        // Extracts the arguments and attempts to cast them based on their appearance
        return args[0] as! [AnyObject]
        //        let a = args[0] as! NSArray
        //        let b = a[0] as! NSArray
        //        return b as [AnyObject]
    }
}


////////////////////
// Cumin
////////////////////

/*
Cumin allows for type-safe deferred method evaluation
through currying. Not sure how to make it play without variadic generics, though there might be a way

TODO:
throw a well known error on miscast
throw a well known error if args size doesn't match
hold method weakly, dont call if deallocd
*/


func cumin(fn: () -> ()) -> ([AnyObject]) -> () {
    return { (args: [AnyObject]) in fn() }
}

func cumin<A>(fn: (A) -> ()) -> ([AnyObject]) -> () {
    return { (args: [AnyObject]) in fn(args[0] as! A) }
}

func cumin<A, B>(fn: (A, B) -> ()) -> ([AnyObject]) -> () {
    return { (args: [AnyObject]) in fn(args[0] as! A, args[1] as! B) }
}

func cumin<A, B, C>(fn: (A, B, C) -> ()) -> ([AnyObject]) -> () {
    return { (args: [AnyObject]) in fn(args[0] as! A, args[1] as! B, args[2] as! C) }
}

func cumin<R: AnyObject>(fn: () -> (R)) -> ([AnyObject]) -> (R) {
    return { (args: [AnyObject]) in fn() }
}

func cumin<A, R: AnyObject>(fn: (A) -> (R)) -> ([AnyObject]) -> (R) {
    return { (args: [AnyObject]) in fn(args[0] as! A) }
}

func cumin<A, B, R: AnyObject>(fn: (A, B) -> (R)) -> ([AnyObject]) -> (R) {
    return { (args: [AnyObject]) in fn(args[0] as! A, args[1] as! B) }
}

func cumin<A, B, C, R: AnyObject>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
    return { (args: [AnyObject]) in fn(args[0] as! A, args[1] as! B, args[2] as! C) }
}




/////////////////
// *None
/////////////////

//// NoneNone
//
//func cumin(fn: () -> ()) -> ([AnyObject]) -> () {
//    return { (args: [AnyObject]) in fn() }
//}
//
//// OneNone
//func cumin<A>(fn: A -> ()) -> ([AnyObject]) -> () {
//    return { (args: [AnyObject]) in fn(args[0] as! A) }
//}
//
//
//// TwoNone
//func cumin<A, B>(fn: (A, B) -> ()) -> ([AnyObject]) -> () {
//    return { (args: [AnyObject]) -> () in fn(args[0] as! A, args[1] as! B) }
//}
//
//// ThreeNone
//func cumin<A, B, C>(fn: (A, B, C) -> ()) -> ([AnyObject]) -> () {
//    return { (args: [AnyObject]) -> () in fn(args[0] as! A, args[2] as! B, args[3] as! C) }
//}
//
///////////////////
//// *One
///////////////////
//// OneOne
//func cumin<A, R>(fn: A -> R) -> ([AnyObject]) -> R {
//    return { (args: [AnyObject]) -> R in fn(args[0] as! A) }
//}
//
//// TwoOne
//func cumin<A, B, R>(fn: (A, B) -> R) -> ([AnyObject]) -> R {
//    return { (args: [AnyObject]) -> R in fn(args[0] as! A, args[1] as! B) }
//}
//
//// ThreeOne
//func cumin<A, B, C, R>(fn: (A, B, C) -> R) -> ([AnyObject]) -> R {
//    return { (args: [AnyObject]) -> R in fn(args[0] as! A, args[1] as! B, args[2] as! C) }
//}




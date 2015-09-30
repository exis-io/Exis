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
    
    public var delegate: RiffleDelegate?
    
    public init(pdid: String) {
        socket = MDWampTransportWebSocket(server:NSURL(string: NODE), protocolVersions:[kMDWampProtocolWamp2msgpack, kMDWampProtocolWamp2json])
        
        // Oh, the hacks you'll see
        session = MDWamp()
        super.init()
        
        session = MDWamp(transport: socket, realm: pdid, delegate: self)
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
    
    
    //MARK: Messaging Patterns with a dash of Cumin
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
    
    
    // MARK: Real Calls
    func _subscribe(endpoint: String, fn: ([AnyObject]) -> ()) {
        // This is the real subscrive method
        session.subscribe(endpoint, onEvent: { (event: MDWampEvent!) -> Void in
            // Trigger the callback
            fn(event.arguments[0] as! [AnyObject])
            
            }) { (err: NSError!) -> Void in
                if let e = err {
                    print("An error occured: ", e)
                }
        }
    }
    
    func _register(endpoint: String, fn: ([AnyObject]) -> ()) {
        session.registerRPC(endpoint, procedure: { (wamp: MDWamp!, invocation: MDWampInvocation!) -> Void in
            
            // WARNING- have to implement return!
            fn(invocation.arguments[0] as! [AnyObject])
            
            wamp.resultForInvocation(invocation, arguments: [], argumentsKw: [:])
            
            }, cancelHandler: { () -> Void in
                print("Register Cancelled!")
            }) { (err: NSError!) -> Void in
                print("Registration completed.")
        }
    }
    
    func _register<R>(endpoint: String, fn: ([AnyObject]) -> (R)) {
        session.registerRPC(endpoint, procedure: { (wamp: MDWamp!, invocation: MDWampInvocation!) -> Void in
            print("Someone called hello: ", invocation)
            
            // WARNING- have to implement return!
            fn(invocation.arguments[0] as! [AnyObject])
            
            }, cancelHandler: { () -> Void in
                print("Register Cancelled!")
            }) { (err: NSError!) -> Void in
                print("Registration completed.")
        }
    }
    
    
    //MARK: OLD CODE
    public func call(endpoint: String, args: AnyObject..., handler: ([AnyObject]) -> ()) {
        session.call(endpoint, payload: args) { (result: MDWampResult!, err: NSError!) -> Void in
            if err != nil {
                print("ERR: ", err)
            }
            else {
                handler(result.arguments == nil ? [] : result.arguments)
            }
        }
    }
    
    public func publish(endpoint: String, args: AnyObject...) {
        session.publishTo(endpoint, args: args, kw: [:], options: [:]) { (err: NSError!) -> Void in
            if let e = err {
                print("Error: ", e)
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

func cumin<R>(fn: () -> (R)) -> ([AnyObject]) -> (R) {
    return { (args: [AnyObject]) in fn() }
}

func cumin<A, R>(fn: (A) -> (R)) -> ([AnyObject]) -> (R) {
    return { (args: [AnyObject]) in fn(args[0] as! A) }
}

func cumin<A, B, R>(fn: (A, B) -> (R)) -> ([AnyObject]) -> (R) {
    return { (args: [AnyObject]) in fn(args[0] as! A, args[1] as! B) }
}

func cumin<A, B, C, R>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
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




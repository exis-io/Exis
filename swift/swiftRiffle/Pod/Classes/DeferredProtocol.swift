//
//  DeferredProtocol.swift
//  Pods
//
//  Created by damouse on 4/26/16.
//
//

import Foundation


public class AbstractDeferred {
    // Automatically invoke callbacks and errbacks if not nil when given arguments
    var callbackArgs: [Any]?
    var errbackArgs: [Any]?
    
    // If an invocation has already occured then the args properties are already set
    // We should invoke immediately
    var _callback: AnyFunction?
    var _errback: AnyFunction?
    
    // The next link in the chain
    var next: [AbstractDeferred] = []
    
    public init() {}
    
    
    func _then<T: AbstractDeferred>(fn: AnyFunction, nextDeferred: T) -> T {
        next.append(nextDeferred)
        if let a = callbackArgs { callback(a) }
        _callback = fn
        return nextDeferred
    }
    
    func _error<T: AbstractDeferred>(fn: AnyFunction, nextDeferred: T) -> T {
        next.append(nextDeferred)
        _errback = fn
        if let a = errbackArgs { errback(a) }
        return nextDeferred
    }
    
    public func callback(args: [Any]) -> Any? {
        callbackArgs = args
        var ret: [Any] = []
        if let cb = _callback { ret = cb.call(args) }
        for n in next { n.callback(ret) }
        return nil
    }
    
    public func errback(args: [Any]) -> Any? {
        errbackArgs = args
        if let eb = _errback { eb.call(args) }
        for n in next { n.errback(args) }
        return nil
    }
    
    public func error(fn: String -> ()) -> Defered<Void> {
        return _error(constrainOneVoid(fn), nextDeferred: Defered<Void>())
    }
}

// The basic deferred class with no extra code specific to riffle
public class Defered<A>: AbstractDeferred, InvokableDeferred {
    public override init() {}
    
    public func then(fn: A -> ())  -> Defered<Void> {
        return _then(constrainOneVoid(fn), nextDeferred: Defered<Void>())
    }
    
    public func chain(fn: () -> Defered) -> Defered<Void> {
        let next = Defered<Void>()
        
        _callback = constrainVoidVoid {
            fn().next.append(next)
        }
        
        return next
    }
    
    public func chain<T: Property>(fn: A -> Defered<T>)  -> Defered<T> {
        let next = Defered<T>()
        
        _callback = constrainOneVoid { (a: A) in
            fn(a).then { s in
                next.callback([s as! AnyObject])
            }.error { s in
                next.errback([s])
            }
        }
        
        return next
    }
}













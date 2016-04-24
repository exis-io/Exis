//
//  Deferred.swift
//  Pods
//
//  Created by damouse on 12/4/15.
//
//  Homebaked, python Twisted inspired deferreds with A+ inspired syntax
//  These guys will chain callbacks and errbacks


import Foundation
import Mantle

public class Deferred: Handler {
    // Callback and Errback ids
    var cb: UInt64 = 0
    var eb: UInt64 = 0
    
    var callbackFuntion: ([Any] -> Any?)? = nil
    var errbackFunction: ([Any] -> Any?)? = nil
    
    var pendingCallback: [Any]?
    var pendingErrback: [Any]?
    
    var next: Deferred?
    
    
    public init() {
        cb = CBID()
        eb = CBID()
        
        Session.handlers[cb] = self
        Session.handlers[eb] = self
    }
    
    // Session has deemed its our time to shine
    func invoke(id: UInt64, args: [Any]) {
        if cb == id {
            callback(args)
        } else if eb == id {
            errback(args)
        }
        
        destroy()
    }
    
    func destroy() {
        Session.handlers[cb] = nil
        Session.handlers[eb] = nil
    }
    
    // Final, internal implementation of addCallback
    public func then(fn: () -> ()) -> Deferred {
        next = Deferred()
        callbackFuntion = { a in return fn() }
        
        if let args = pendingCallback {
            pendingCallback = nil
            callback(args)
        }
        
        return next!
    }
    
    public func error(fn: (String) -> ()) -> Deferred {
        next = Deferred()
        errbackFunction = { a in fn(a[0] as! String) }
        
        if let args = pendingErrback {
            pendingErrback = nil
            errback(args)
        }
        
        return next!
    }
    
    public func callback(args: [Any]) -> Any? {
        // Fires off a deferred chain recursively. TODO: work in error logic, recovery, propogation, etc
        var ret: Any?
        
        if let handler = callbackFuntion {
            // if the next result is a deferred, wait for it to complete before returning (?)
            ret = handler(args)
            
            // follow the chain
            if let n = next {
                if let arrayReturn = ret as? [Any] {
                    return n.callback(arrayReturn)
                }
                
                return n.callback([ret])
            } else {
                return ret
            }
        } else {
            pendingCallback = args
            return nil
        }
    }
    
    public func errback(args: [Any]) -> Any? {
        if let handler = errbackFunction {
            // if the next result is a deferred, wait for it to complete before returning (?)
            let ret = handler(args)
            
            // follow the chain, propogate the calback to the next deferred
            if let n = next {
                return n.errback(args)
            } else {
                return ret
            }
        } else {
            // No chain exists. TODO: Send the error to some well-known place
            // Riffle.warn("Unhandled error: \(args)")
            
            pendingErrback = args
            return nil
        }
    }
}

// Contains handler "then"s to replace handler functions
public class HandlerDeferred: Deferred {
    var domain: Domain!
    
    public override func then(fn: () -> ()) -> Deferred {
        // this override is a special case. It overrides the base then, but cant go in the extension
        return _then([]) { a in return fn() }
    }
    
    public func _then(types: [Any], _ fn: [Any] -> ()) -> Deferred {
        next = Deferred()
        domain.callCore("CallExpects", args: [cb, types])
        callbackFuntion = { a in return fn(a) }
        return next!
    }
}



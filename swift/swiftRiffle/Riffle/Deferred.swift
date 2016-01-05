//
//  Deferred.swift
//  Pods
//
//  Created by damouse on 12/4/15.
//
//  Homebaked, python Twisted inspired deferreds with A+ inspired syntax
//  These guys will chain callbacks and errbacks


import Foundation

public class Deferred {
    // Callback and Errback ids
    var cb: UInt64 = 0
    var eb: UInt64 = 0
    
    var callbackFuntion: ([Any] -> Any?)? = nil
    var errbackFunction: ([Any] -> Any?)? = nil
    
    var next: Deferred?
    
    // Called when a callback has been assigned. Used internally for Call cuminication
    var onCallbackAssigned: (([Any]) -> ())? = nil
    
    
    public init() {}
    
    public init(domain: Domain) {
        // Automatically creates and sets callback and errback assignments for the given domain
        cb = CBID()
        eb = CBID()
        
        domain.deferreds[eb] = self
        domain.deferreds[cb] = self
    }
    
    // Final, internal implementation of addCallback
    public func then(fn: () -> ()) -> Deferred {
        next = Deferred()
        
        if let cuminication = onCallbackAssigned {
            cuminication([])
        }
        
        callbackFuntion = { a in return fn() }
        
        return next!
    }
    
    public func _then(fn: [Any] -> ()) -> Deferred {
        next = Deferred()
        
        if let cuminication = onCallbackAssigned {
            cuminication([])
        }
        
        callbackFuntion = { a in return fn(a) }
        
        return next!
    }
    
    public func error(fn: (String) -> ()) -> Deferred {
        next = Deferred()
        errbackFunction = { a in fn(a[0] as! String) }
        return next!
    }
    
    public func callback(args: [Any]) -> Any? {
        if let cb = callbackFuntion {
             // if the next result is a deferred, wait for it to complete before returning (?)
            return cb(args)
        } else {
            // follow the chain, propogate the calback to the next deferred
            if let n = next {
                n.callback(args)
            }
            
            // No chain exists. Do nothing
            return nil
        }
    }
    
    public func errback(args: [Any]) -> Any? {
        if let eb = errbackFunction {
            return eb(args)
        } else {
            // Follow the chain, propogate the error to the next deferred
            if let n = next {
                n.errback(args)
            }
            
            // No chain exists. TODO: Send the error to some well-known place
            WarnLog("Unhandled error: \(args)")
            return nil
        }
    }
}

// Contains handler "then"s to replace handler functions
public class HandlerDeferred: Deferred {
    
}
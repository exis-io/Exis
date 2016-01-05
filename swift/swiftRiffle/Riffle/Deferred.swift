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
    var callback: ([Any] -> Any?)? = nil
    var errback: ([Any] -> Any?)? = nil
    
    var next: Deferred?
    
    // Called when a callback has been assigned. Used internally for Call cuminication
    var onCallbackAssigned: (([Any]) -> ())? = nil
    
    public init() {}
    
    // Final, internal implementation of addCallback
    func _then(fn: ([Any]) -> Any?) -> Deferred {
        next = Deferred()
        
        if let cuminication = onCallbackAssigned {
            // TODO: pass types of cuminicated function here
            cuminication([])
        }
        
        return next!
    }
    
    public func error(fn: (String) -> ()) -> Deferred {
        next = Deferred()
        errback = { a in fn(a[0] as! String) }
        return next!
    }
    
    // TODO: try/catch the callback and errback, trigger the next one if appropriate
    public func callback(args: [Any]) -> Any? {
        if let cb = callback {
            return cb(args)
        } else {
            return nil
        }
    }
    
    public func errback(args: [Any]) -> Any? {
        if let eb = errback {
            return eb(args)
        } else {
            return nil
        }
    }
}
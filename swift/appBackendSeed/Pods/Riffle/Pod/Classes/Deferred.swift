//
//  Deferred.swift
//  Pods
//
//  Created by damouse on 12/4/15.
//
//  Homebaked, python Twisted inspired deferreds.
//
//  True twisted style chain hopping has not been implemented

import Foundation


public class Deferred {
    var _callback: [((AnyObject?) -> AnyObject?)] = []
    var _errback: [((AnyObject?) -> AnyObject?)] = []
    
    var fired = false
    
    public init() {}
    
    public func callback(args: AnyObject? = nil) {
        if fired {
            //print("Defereds can only fire once!")
            return
        }
        
        fired = true
        var result = args
        
        while _callback.count > 0 {
            let cb = _callback.removeFirst()
            result = cb(result)
        }
        
        _errback = []
    }
    
    public func errback(args: AnyObject? = nil) {
        if fired {
            //print("Defereds can only fire once!")
            return
        }
        
        fired = true
        var result = args
        
        while _errback.count > 0 {
            let cb = _errback.removeFirst()
            result = cb(result)
        }
        
        _callback = []
    }
    
    
    public func addCallback(cb: (AnyObject?) -> (AnyObject?)) -> Deferred {
        _callback.append(cb)
        return self
    }
    
    public func addErrback(cb: (AnyObject?) -> (AnyObject?)) -> Deferred {
        _errback.append(cb)
        return self
    }
}
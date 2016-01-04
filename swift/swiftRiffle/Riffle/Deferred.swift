//
//  Deferred.swift
//  Pods
//
//  Created by damouse on 12/4/15.
//
//  Homebaked, python Twisted inspired deferreds.
//
//  True twisted style chain hopping has not been implemented

// import Foundation

 public class Deferred {
     var _callback: ((AnyObject?) -> AnyObject?)? = nil
     var _errback: ((AnyObject?) -> AnyObject?)? = nil
    
     var fired = false
    
     public init() {}
    
     public func callback(args: AnyObject? = nil) -> AnyObject? {
         if fired {
             print("Defereds can only fire once!")
             return nil
         }
        
         fired = true
        
         if let cb = _callback {
             return cb(args)
         } else {
             print("No callback registered")
             return nil
         }
     }
    
     public func errback(args: AnyObject? = nil) -> AnyObject? {
         if fired {
             print("Defereds can only fire once!")
             return nil
         }
        
         fired = true
        
         if let cb = _errback {
             return cb(args)
         } else {
             print("No callback registered")
             return nil
         }
     }
    
    
     public func addCallback(cb: (AnyObject?) -> (AnyObject?)) -> Deferred {
         _callback = cb
         return self
     }
    
     public func addErrback(cb: (AnyObject?) -> (AnyObject?)) -> Deferred {
         _errback = cb
         return self
     }
 }
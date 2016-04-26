//
//  Crust.swift
//  Pods
//
//  Created by damouse on 4/22/16.
//
//  Top level interface to to core using Mantle v2. This should be the only 
//  access to the mantle.

import Foundation
import Mantle

/**
 Interact with the Riffle core through the Mantle, a reflective RPC-like messaging bus.
 
 - returns: Deferred
 - parameter target:        The name of the thing being accessed
 - parameter deferred:      Invoked with the results of an operation
 - parameter address:       If this operation creates an object, assign it this address
 - parameter object:        If "target" refers to a method (a function on a struct) then this is the address of that object
 - parameter args:          Arguments to call the function with 
 - parameter synchronous:   If set then "Send" will not return until the core finishes the operation, else it returns immediately
*/
func sendCore(target: String, deferred: Deferred = Deferred(), address: UInt64 = 0, object: UInt64 = 0, args: [Any] = [], synchronous: Bool = false) -> Deferred {
    var invocation: [Any] = [target, deferred.cb, deferred.eb, address, object]
    invocation.appendContentsOf(args)
    
    // print("Serialization before: \(args) after: \(JSON.from(invocation).serialize(DefaultJSONSerializer()))")
    
    // let data = try! NSJSONSerialization.dataWithJSONObject(args as! AnyObject, options: .PrettyPrinted)
    // let repacked = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
    // print("Repacked: \(repacked)")
    
    Send(JSON.from(invocation).serialize(DefaultJSONSerializer()).cString(), synchronous ? 1 : 0)
    return deferred
}

// Base class for all objects that mirror a core object
public class CoreClass {
    let address = CBID()
    
    // Calls this class's constrcutor
    func initCore(klass: String, _ args: [Any]) {
        sendCore("New\(klass)", address: address, args: args, synchronous: true)
    }
    
    func callCore(target: String, deferred: Deferred = Deferred(), args: [Any] = [], synchronous: Bool = false) -> Deferred {
        // print("Calling to core with args: \(args)")
        return sendCore(target, deferred: deferred, object: address, args: args, synchronous: synchronous)
    }
    
    deinit {
        // We may have to manually call "leave" on domains and app domains, they have reference cycles in the core
        // sendCore("Free", address: 1, args: [address])
    }
}

// Represents a session with the core. Replaces the receive loop from App
// All deferreds are handled here, but handlers are managed by their respective AppDomain
// ... but why not just handle them all here? The only tricky bit is having 
// the core push us messages wrt removing handlers. Seems reasonable?
class Session {
    static var handlers: [UInt64: Handler] = [:]
    static var receiving = false
    
    class func receive() {
        if receiving { return }
        sendCore("SetSafeSSLOff", synchronous:true)
        receiving = true
        
        while true {
            var (i, args) = decode(Receive())
            //  print("Crust has invocation \(i) \(args)")
            
            if i == 0 {
                receiving = false
                break
            }
            
            if let handler = handlers[i] {
                handler.invoke(i, args: args)
            } else {
                print("Unhandled invocation: \(i), \(args)")
            }
        }
        
        print("Crust session closing")
    }
}

protocol Handler {
    func invoke(id: UInt64, args: [Any])
    func destroy()
}

// Wrapper for registrations and subscriptions
class DomainHandler: Handler {
    let id = CBID()
    var curriedHandler: ([Any]) -> ()
    
    init(fn: ([Any]) -> ()) {
        curriedHandler = fn
        Session.handlers[id] = self
    }
    
    func invoke(id: UInt64, args: [Any]) {
        // This is never called if the runloop is processing. Be careful with this
        self.curriedHandler(args)
        
//        #if os(Linux)
//            curriedHandler(args)
//        #else
////            dispatch_async(dispatch_get_main_queue()) {
////                print("Async invocation triggering")
////                self.curriedHandler(args)
////            }
//            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//                self.curriedHandler(args)
//            })
//        #endif
    }
    
    func destroy() {
        Session.handlers.removeValueForKey(id)
    }
}















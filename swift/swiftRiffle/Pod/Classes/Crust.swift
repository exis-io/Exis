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

// Send some message to the core. Automatically creates a Deferred object.
// This overload does not take a handler id
func sendCore(target: String, _ args: [Any]) -> Deferred {
    let d = Deferred()
    return sendCore(target, deferred: d, handler: 0, address: 0, args)
}

func sendCore(target: String, handler: UInt64, _ args: [Any]) -> Deferred {
    let d = Deferred()
    return sendCore(target, deferred: d, handler: handler, address: 0, args)
}


func sendCore(target: String, handler: UInt64, address: UInt64, _ args: [Any]) -> Deferred {
    let d = Deferred()
    return sendCore(target, deferred: d, handler: handler, address: address, args)
}

func sendCore(target: String, deferred: Deferred, handler: UInt64, address: UInt64, _ args: [Any]) -> Deferred {
    var invocation: [Any] = [target, deferred.cb, deferred.eb, handler, address]
    invocation.appendContentsOf(args)
    
    let json = JSON.from(invocation)
    let jsonString = json.serialize(DefaultJSONSerializer())
    // print("Serialized string: \(jsonString)")
    
    Send(jsonString.cString())
    
    return deferred
}

// Base class for all objects that mirror a core object
public class CoreClass {
    let address = CBID()
    
    // Calls this class's constrcutor
    func initCore(klass: String, _ args: [Any]) {
        sendCore("New\(klass)", handler: address, args)
    }
    
    // Call a core method on this object
    func callCore(target: String, _ args: [Any]) -> Deferred {
        return sendCore(target, handler: 0, address: address, args)
    }
    
    func callCore(target: String, deferred: Deferred, _ args: [Any]) -> Deferred {
        return sendCore(target, deferred: deferred, handler: 0, address: address, args)
    }
    
    deinit {
        // We may have to manually call "leave" on domains and app domains, they have reference cycles in the core
        sendCore("Free", handler: 1, [address])
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
        receiving = true
        
        while true {
            var (i, args) = decode(Receive())
            // print("Crust session has \(i): \(args)")
            
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
        #if os(Linux)
            curriedHandler(args)
        #else
//            dispatch_async(dispatch_get_main_queue()) {
//                print("Async invocation triggering")
//                self.curriedHandler(args)
//            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                self.curriedHandler(args)
            })
        #endif
    }
    
    func destroy() {
        Session.handlers.removeValueForKey(id)
    }
}















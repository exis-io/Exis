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
    return sendCore(target, deferred: d, handler: 1, args)
}

func sendCore(target: String, handler: UInt64, _ args: [Any]) -> Deferred {
    let d = Deferred()
    return sendCore(target, deferred: d, handler: handler, args)
}

func sendCore(target: String, deferred: Deferred, handler: UInt64, _ args: [Any]) -> Deferred {
    var invocation: [Any] = [target, deferred.cb, deferred.eb, handler]
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
        return sendCore(target, handler: address, args)
    }
    
    func callCore(target: String, deferred: Deferred, _ args: [Any]) -> Deferred {
        return sendCore(target, deferred: deferred, handler: address, args)
    }
    
    deinit {
        // We may have to manually call "leave" on domains and app domains
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

            if i == 0 {
                receiving = false
                break
            }

            #if os(Linux)
                handleInvocation(i, arguments: args)
            #else
            dispatch_async(dispatch_get_main_queue()) {
                self.handleInvocation(i, arguments: args)
            }
            #endif
        }
    }
    
    class func handleInvocation(i: UInt64, arguments: [Any]) {
        if let handler = handlers[i] {
            handler.invoke(i, args: arguments)
        } else {
            Riffle.warn("Unhandled invocation: \(i)")
        }
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
        curriedHandler(args)
    }
    
    func destroy() {
        Session.handlers.removeValueForKey(id)
    }
}















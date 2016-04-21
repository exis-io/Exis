//
//  App.swift
//  Pods
//
//  Created by damouse on 3/7/16.
//
//

import Foundation
import Mantle

class App {
    var mantleDomain: UInt64
    
    var deferreds: [UInt64: Deferred] = [:]
    var handlers: [UInt64: [Any] -> ()] = [:]
    var registrations: [UInt64: [Any] -> [Any]] = [:]
    
    
    init(domain: UInt64) {
        mantleDomain = domain
    }
    
    func handleInvocation(i: UInt64, arguments: [Any]) {
        var args = arguments
        
        if let d = self.deferreds[i] {
            self.deferreds[d.cb] = nil
            self.deferreds[d.eb] = nil
            
            if d.cb == i {
                d.callback(args)
            } else if d.eb == i {
                d.errback(args)
            }
            
        } else if let fn = self.handlers[i] {
            fn(args)
        } else if let fn = self.registrations[i] {
            let resultId = args.removeAtIndex(0) as! Double
            Yield(self.mantleDomain, UInt64(resultId), marshall(fn(args)))
        }
    }
    
    func receive() {
        while true {
            var (i, args) = decode(Receive(self.mantleDomain))
            #if os(Linux)
                handleInvocation(i, arguments: args)
            #else
            dispatch_async(dispatch_get_main_queue()) {
                self.handleInvocation(i, arguments: args)
            }
            #endif
        }
    }
}

// Here for testing. May break terribly on ubuntu, in which case core changes are needed to allow tupled returns
// Takes a tuple and returns it as an array
func unpackTuple(tuple: Any) -> [Any] {
    let mirror = Mirror(reflecting: tuple)
    return mirror.children.map { $0.value as Any }
}
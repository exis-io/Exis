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
    let cb = CBID()
    let eb = CBID()

    var callbackFuntion: ([Any] -> Any?)? = nil
    var errbackFunction: ([Any] -> Any?)? = nil
    var next: Deferred?
    
    var callbackOccured: [Any]? = nil
    var errbackOccured: [Any]? = nil
    
    
    // this should not be public
    public init() {
        Session.handlers[cb] = self
        Session.handlers[eb] = self
    }
    
    func _then(fn: [Any] -> ()) -> Deferred {
        next = Deferred()
        callbackFuntion = { a in return fn(a) }

        if let args = callbackOccured {
            callbackOccured = nil
            callback(args)
            next!.callback(args)
        }

        return next!
    }

    func _error(fn: (String) -> ()) -> Deferred {
        next = Deferred()
        errbackFunction = { a in fn(a[0] as! String) }
        
        if let args = errbackOccured {
            errback(args)
            next!.errback(args)
        }

        return next!
    }

    public func callback(args: [Any]) -> Any? {
        callbackOccured = args
        print(args)
        if let f = callbackFuntion {
            if let d = f(args) as? Deferred {
                print("Have a deferred")
            }
        }
        if let n = next { n.callback(args) }
        return nil
    }

    public func errback(args: [Any]) -> Any? {
        errbackOccured = args
        if let handler = errbackFunction { handler(args) }
        if let n = next { n.errback(args) }
        return nil
    }
    
    // Session has deemed its our time to shine. Fire off this deferred
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
    
    public func then(fn: () -> ()) -> Deferred {
        return _then() { a in fn() }
    }
    
//    public func then(fn: () -> (Deferred)) -> Deferred {
//        return _then() { a in fn() }
//    }
    
    public func error(fn: (String) -> ()) -> Deferred {
        return _error(fn)
    }
}

// Contains handler "then"s to replace handler functions
public class HandlerDeferred: Deferred {
    var domain: Domain!
    
    public override func then(fn: () -> ()) -> Deferred {
        // this override is a special case. It overrides the base then, but cant go in the extension
        return _then([]) { a in return fn() }
    }
    
    func _then(types: [Any], _ fn: [Any] -> ()) -> Deferred {
        domain.callCore("CallExpects", args: [cb, types])
        return _then(fn)
    }
}

// A deferred that callsback with a fixed number of arguments and types
public class OneDeferred<A: PR>: Deferred {
    public func then(fn: (A) -> ()) -> Deferred {
        return _then() { a in return fn(A.self <- a[0]) }
    }
}

public class TwoDeferred<A: PR, B: PR>: Deferred {
    public func then(fn: (A, B) -> ()) -> Deferred {
        return _then() { a in return fn(A.self <- a[0], B.self <- a[1]) }
    }
}

public class ThreeDeferred<A: PR, B: PR, C: PR>: Deferred {
    public func then(fn: (A, B, C) -> ()) -> Deferred {
        return _then() { a in return fn(A.self <- a[0], B.self <- a[1], C.self <- a[2]) }
    }
}

public class FourDeferred<A: PR, B: PR, C: PR, D: PR>: Deferred {
    public func then(fn: (A, B, C, D) -> ()) -> Deferred {
        return _then() { a in return fn(A.self <- a[0], B.self <- a[1], C.self <- a[2], D.self <- a[3]) }
    }
}

public class FiveDeferred<A: PR, B: PR, C: PR, D: PR, E: PR>: Deferred {
    public func then(fn: (A, B, C, D, E) -> ()) -> Deferred {
        return _then() { a in return fn(A.self <- a[0], B.self <- a[1], C.self <- a[2], D.self <- a[3], E.self <- a[4]) }
    }
}

public class SixDeferred<A: PR, B: PR, C: PR, D: PR, E: PR, F: PR>: Deferred {
    public func then(fn: (A, B, C, D, E, F) -> ()) -> Deferred {
        return _then() { a in return fn(A.self <- a[0], B.self <- a[1], C.self <- a[2], D.self <- a[3], E.self <- a[4], F.self <- a[5]) }
    }
}


// Saved old code

//    var callbackFuntion: ([Any] -> Any?)? = nil
//    var errbackFunction: ([Any] -> Any?)? = nil
//
//    var pendingCallback: [Any]?
//    var pendingErrback: [Any]?
//
//    var next: Deferred?
//    var root: Deferred!


//    func _then(fn: [Any] -> ()) -> Deferred {
//        next = Deferred()
//        callbackFuntion = { a in return fn(a) }
//
//        if let args = pendingCallback {
//            pendingCallback = nil
//            callback(args)
//            next!.callback(args)
//        }
//
//        return next!
//    }
//
//    func _error(fn: (String) -> ()) -> Deferred {
//        next = Deferred()
//        errbackFunction = { a in fn(a[0] as! String) }
//
//        if let args = pendingErrback {
//            pendingErrback = nil
//            errback(args)
//            next!.errback(args)
//        }
//
//        return next!
//    }
//
//    public func callback(args: [Any]) -> Any? {
//        // Fires off a deferred chain recursively. TODO: work in error logic, recovery, propogation, etc
//        var ret: Any?
//
//        if let handler = callbackFuntion {
//            // if the next result is a deferred, wait for it to complete before returning (?)
//            ret = handler(args)
//
//            // follow the chain
//            if let n = next {
//                if let arrayReturn = ret as? [Any] {
//                    return n.callback(arrayReturn)
//                }
//
//                return n.callback([ret])
//            } else {
//                return ret
//            }
//        } else {
//            pendingCallback = args
//            return nil
//        }
//    }
//
//    public func errback(args: [Any]) -> Any? {
//        if let handler = errbackFunction {
//            // if the next result is a deferred, wait for it to complete before returning (?)
//            let ret = handler(args)
//
//            // follow the chain, propogate the calback to the next deferred
//            if let n = next {
//                return n.errback(args)
//            } else {
//                return ret
//            }
//        } else {
//            // No chain exists. TODO: Send the error to some well-known place
//            // Riffle.warn("Unhandled error: \(args)")
//
//            pendingErrback = args
//            return nil
//        }
//    }



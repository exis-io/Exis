//
//  DeferredProtocol.swift
//  Pods
//
//  Created by damouse on 4/26/16.
//
//

import Foundation


protocol DeferredType {
    var fired: Bool { get set }
    
    var callbackArgs: [Any]? { get set }
    var errbackArgs: [Any]? { get set }
    
    func callback(args: [Any])
    func errback(args: [Any])
}


// The generic kind is the type of the next deferred
public class BaseDeferred:  DeferredType, Handler {
    // Callback and Errback ids
    var cb: UInt64? = nil
    var eb: UInt64? = nil
    
    var next: [BaseDeferred] = []
    var fired: Bool = false
    
    public var callbackArgs: [Any]?
    public var errbackArgs: [Any]?
    
    var _callback: AnyFunction?
    var _errback: AnyFunction?
    
    
    public init() {}
    
    public func registerWithSession() {
        cb = CBID()
        eb = CBID()
        Session.handlers[cb!] = self
        Session.handlers[eb!] = self
    }
    
    public func callback(args: [Any]) {
        callbackArgs = args
        fired = true
        let ret = _callback?.call(args)
        
        // If we detect a continuation from our callback then we don't follow the deferred chain
        // Instead, we slip that deferred into the chain between us and next, disconect the rest of the
        // chain from us and connect it to the new deferred
        if ret != nil && ret!.count == 1 {
            if let continuation = ret![0] as? BaseDeferred {
                continuation.callbackArgs = callbackArgs
                continuation.errbackArgs = errbackArgs
                continuation.next = next
                next = []
            } else {
                for n in next { n.callback(ret == nil ? [] : ret!) }
            }
        } else {
            for n in next { n.callback(ret == nil ? [] : ret!) }
        }
    }
    
    // Note that callbacks pipe previous results into subsequent callbacks,
    // but errbacks pass the same error string to each. This will be changed.
    public func errback(args: [Any]) {
        errbackArgs = args
        fired = true
        _errback?.call(args)
        for n in next { n.errback(args) }
    }
    
    func _then(fn: AnyFunction) {
        _callback = fn
        if let a = callbackArgs { callback(a) }
    }
    
    func _error(fn: AnyFunction) {
        _errback = fn
        if let a = errbackArgs { errback(a) }
    }
    
    public func invoke(id: UInt64, args: [Any]) {
        if cb == id {
            callback(args)
        } else if eb == id {
            errback(args)
        }
        
        destroy()
    }
    
    public func destroy() {
        if let _ = cb {
            Session.handlers[cb!] = nil
            Session.handlers[eb!] = nil
        }
    }
}


// These are the specializations possible for deferreds. By mixing and matching these
// into named protocols you can constrain how a deferred behaves. These guys mostly just declare new
// signatures for then and error


// Errback: String -> Void
public protocol EBStringVoid {
    func error(fn: (String) -> ()) -> BaseDeferred
}

extension BaseDeferred: EBStringVoid {
    public func error(fn: String -> ())  -> BaseDeferred {
        let d = BaseDeferred()
        next.append(d)
        _error(constrainOneVoid(fn))
        return d
    }
}


// Callback: Void -> Void
public protocol VoidVoid {
    func then(fn: () -> ()) -> BaseDeferred
}

extension BaseDeferred: VoidVoid {
    public func then(fn: () -> ())  -> BaseDeferred {
        let d = BaseDeferred()
        next.append(d)
        _then(constrainVoidVoid(fn))
        return d
    }
}

// Callback: Void -> Void
public protocol OneVoid {
    func then<A: PR>(fn: A -> ()) -> BaseDeferred
}

extension BaseDeferred: OneVoid {
    public func then<A: PR>(fn: A -> ())  -> BaseDeferred {
        let d = BaseDeferred()
        next.append(d)
        _then(constrainOneVoid(fn))
        return d
    }
}

public protocol VoidOne {
    func then<A: PR>(fn: () -> A) -> BaseDeferred
}

extension BaseDeferred: VoidOne {
    public func then<A: PR>(fn: () -> A)  -> BaseDeferred {
        let d = BaseDeferred()
        next.append(d)
        _then(constrainVoidOne(fn))
        return d
    }
}


public protocol VoidDeferred {
    func then<A: BaseDeferred>(fn: () -> A) -> BaseDeferred
}

extension BaseDeferred: VoidDeferred {
    public func then<A: BaseDeferred>(fn: () -> A)  -> BaseDeferred {
        let d = BaseDeferred()
        next.append(d)
        _then(constrainVoidOne(fn))
        return d
    }
}


// Callback: Void -> T where subsequent callbacks must return T
public protocol ConstrainedVoidOne {
    associatedtype T: Property
    func then<B: PR>(fn: B -> T) -> DeferredResults<T>
}

public class DeferredResults<A: PR>: BaseDeferred, ConstrainedVoidOne {
    public func then<B: PR>(fn: B -> A)  -> DeferredResults<A> {
        let d = DeferredResults<A>()
        next.append(d)
        _then(constrain(fn))
        return d
    }
}

public class DeferredParams<A: PR>: BaseDeferred {
    public override init() {}
    
    func then<B: PR>(fn: A -> B)  -> DeferredParams<B> {
        let d = DeferredParams<B>()
        next.append(d)
        _then(constrain(fn))
        return d
    }
    
    //    func then(fn: A -> ()) -> DeferredChain {
    //        let d = Deferred()
    //        next.append(d)
    //        _then(constrainOneVoid(fn))
    //        return d
    //    }
}

// Allows users or developers to invoke callbacks
public protocol Invokable {
    func callback(args: [Any])
    func errback(args: [Any])
}

extension BaseDeferred: Invokable {}


// Composition
// Here protocols from above are combined into useful sets of functionality
// by mixing and matching the protocols above to create useful interfaces

// A boring deferred that doesn't return anything terribly useful
public protocol DeferredVoid: EBStringVoid, VoidVoid, Invokable {}
extension BaseDeferred: DeferredVoid {}

// Allows deferred objects to be returned from within then blocks
public protocol DeferredChain: VoidDeferred, EBStringVoid, OneVoid, Invokable {}
extension BaseDeferred: DeferredChain {}

// Allows non-deferred objects to be passed from block to block
public protocol DeferredValueChain: EBStringVoid, OneVoid, Invokable, VoidOne {}
extension BaseDeferred: DeferredValueChain {}

// Results of then are constrained to the given type
public protocol DeferredConstrainedResults: ConstrainedVoidOne, EBStringVoid {}
extension DeferredResults: DeferredConstrainedResults {}

// Parameters of then are constrained by the return of previous signature
public protocol DeferredConstrainedParams: EBStringVoid {}
extension DeferredParams: DeferredConstrainedParams {}

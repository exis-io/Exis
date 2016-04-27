
import Foundation


protocol Convertible {
    // Convert the given argument to this type
    static func to<T: AnyObject>(from: T) -> Self
    
    // Get a serializable value from this type
    func from() -> AnyObject
}

// By creating a base "implementation" of the protocol we can inject
// CN into a lot of stuff without having to implement each individually
protocol BaseConvertible: Convertible {}

extension BaseConvertible {
    static func to<T: AnyObject>(from: T) -> Self { return from as! Self }
    func from() -> AnyObject { return self as! AnyObject }
}

typealias CN = Convertible

extension String : BaseConvertible { }
extension Bool : BaseConvertible { }



protocol AnyClosureType {
    func call(args: [AnyObject]) -> [AnyObject]
}

protocol ClosureType {
    associatedtype ParameterTypes
    associatedtype ReturnTypes
    var handler: ParameterTypes -> ReturnTypes { get }
}

// Concrete and invokable. Doesn't care about types
class BaseClosure<A, B>: AnyClosureType, ClosureType {
    let handler: A -> B
    var curried: ([AnyObject] -> [AnyObject])!
    
    // For some reason the generic constraints aren't forwarded correctly when
    // the curried function is passed along, so it gets its own method below
    // You must call setCurry immediately after init!
    init(fn: A -> B) {
        handler = fn
    }
    
    func call(args: [AnyObject]) -> [AnyObject] {
        return curried(args)
    }
    
    func setCurry(fn: [AnyObject] -> [AnyObject]) -> Self {
        curried = fn
        return self
    }
}

// Generates constrained concrete closures. Some of these methods have different names
// instead of overloads to cases where non-generic overrides get called instead of the generic ones
func constrainVoidVoid(fn: () -> ())  -> BaseClosure<Void, Void> {
    return BaseClosure(fn: fn).setCurry { a in fn(); return [] }
}

func constrainOneVoid<A>(fn: (A) -> ()) -> BaseClosure<A, Void> {
    return BaseClosure(fn: fn).setCurry { a in fn(a[0] as! A); return [] }
}

func constrainVoidOne<A>(fn: () -> A) -> BaseClosure<Void, A> {
    return BaseClosure(fn: fn).setCurry { a in [fn() as! AnyObject] }
}

func constrain<A: CN, B: CN, C: CN>(fn: (A, B) -> C)  -> BaseClosure<(A, B), C> {
    return BaseClosure(fn: fn).setCurry { a in return [fn(A.to(a[0]), B.to(a[1])) as! AnyObject]}
}

func constrain<A: CN, B: CN>(fn: A -> B)  -> BaseClosure<A, B> {
    return BaseClosure(fn: fn).setCurry { a in return [fn(A.to(a[0])) as! AnyObject]}
}




protocol DeferredType {
    var fired: Bool { get set }
    
    var callbackArgs: [AnyObject]? { get set }
    var errbackArgs: [AnyObject]? { get set }
    
    func callback(args: [AnyObject])
    func errback(args: [AnyObject])
}


// The generic kind is the type of the next deferred
class Deferred: DeferredType {
    var next: [Deferred] = []
    var fired: Bool = false
    
    var callbackArgs: [AnyObject]?
    var errbackArgs: [AnyObject]?
    
    var _callback: AnyClosureType?
    var _errback: AnyClosureType?
    
    
    init() {}
    
    func callback(args: [AnyObject]) {
        callbackArgs = args
        fired = true
        let ret = _callback?.call(args)
        
        // If we detect a continuation from our callback then we don't follow the deferred chain
        // Instead, we slip that deferred into the chain between us and next, disconect the rest of the
        // chain from us and connect it to the new deferred
        if ret != nil && ret!.count == 1 {
            if let continuation = ret![0] as? Deferred {
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
    func errback(args: [AnyObject]) {
        errbackArgs = args
        fired = true
        _errback?.call(args)
        for n in next { n.errback(args) }
    }
    
    func _then(fn: AnyClosureType) {
        _callback = fn
        if let a = callbackArgs { callback(a) }
    }
    
    func _error(fn: AnyClosureType) {
        _errback = fn
        if let a = errbackArgs { errback(a) }
    }
}


// These are the specializations possible for deferreds. By mixing and matching these
// into named protocols you can constrain how a deferred behaves. These guys mostly just declare new 
// signatures for then and error


// Errback: String -> Void
protocol EBStringVoid {
    func error(fn: (String) -> ()) -> Deferred
}

extension Deferred: EBStringVoid {
    func error(fn: String -> ())  -> Deferred {
        let d = Deferred()
        next.append(d)
        _error(constrainOneVoid(fn))
        return d
    }
}


// Callback: Void -> Void
protocol VoidVoid {
    func then(fn: () -> ()) -> Deferred
}

extension Deferred: VoidVoid {
    func then(fn: () -> ())  -> Deferred {
        let d = Deferred()
        next.append(d)
        _then(constrainVoidVoid(fn))
        return d
    }
}

// Callback: Void -> Void
protocol OneVoid {
    func then<A: CN>(fn: A -> ()) -> Deferred
}

extension Deferred: OneVoid {
    func then<A: CN>(fn: A -> ())  -> Deferred {
        let d = Deferred()
        next.append(d)
        _then(constrainOneVoid(fn))
        return d
    }
}

protocol VoidOne {
    func then<A: CN>(fn: () -> A) -> Deferred
}

extension Deferred: VoidOne {
    func then<A: CN>(fn: () -> A)  -> Deferred {
        let d = Deferred()
        next.append(d)
        _then(constrainVoidOne(fn))
        return d
    }
}


protocol VoidDeferred {
    func then<A: Deferred>(fn: () -> A) -> Deferred
}

extension Deferred: VoidDeferred {
    func then<A: Deferred>(fn: () -> A)  -> Deferred {
        let d = Deferred()
        next.append(d)
        _then(constrainVoidOne(fn))
        return d
    }
}


// Callback: Void -> T where subsequent callbacks must return T
protocol ConstrainedVoidOne {
    associatedtype T: Convertible
    func then<B: CN>(fn: B -> T) -> DeferredResults<T>
}

class DeferredResults<A: CN>: Deferred, ConstrainedVoidOne {
    func then<B: CN>(fn: B -> A)  -> DeferredResults<A> {
        let d = DeferredResults<A>()
        next.append(d)
        _then(constrain(fn))
        return d
    }
}

class DeferredParams<A: CN>: Deferred {
    func then<B: CN>(fn: A -> B)  -> DeferredParams<B> {
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
protocol Invokable {
    func callback(args: [AnyObject])
    func errback(args: [AnyObject])
}

extension Deferred: Invokable {}


// Composition
// Here protocols from above are combined into useful sets of functionality
// by mixing and matching the protocols above to create useful interfaces

// A boring deferred that doesn't return anything terribly useful
protocol DeferredVoid: EBStringVoid, VoidVoid, Invokable {}
extension Deferred: DeferredVoid {}

// Allows deferred objects to be returned from within then blocks
protocol DeferredChain: VoidDeferred, EBStringVoid, OneVoid, Invokable {}
extension Deferred: DeferredChain {}

// Allows non-deferred objects to be passed from block to block
protocol DeferredValueChain: EBStringVoid, OneVoid, Invokable, VoidOne {}
extension Deferred: DeferredValueChain {}

// Results of then are constrained to the given type
protocol DeferredConstrainedResults: ConstrainedVoidOne, EBStringVoid {}
extension DeferredResults: DeferredConstrainedResults {}

// Parameters of then are constrained by the return of previous signature
protocol DeferredConstrainedParams: EBStringVoid {}
extension DeferredParams: DeferredConstrainedParams {}


// From here on out we build up specialized deferred classes.
// Each class represents some known kind of response. The protocols
// are built out to constrain the types of deferreds that can be passed


// Returns generically typed deferreds
//
//extension DeferredContinuing: DeferredStringError {
//
//    func then<T: CN>(fn: () -> T) -> DeferredParamConstrained<T> {
//        let d = DeferredParamConstrained<T>()
//        next.append(d)
//        _then(constrainVoidOne(fn))
//        return d
//    }
//
//    func error(fn: (String) -> ()) -> DeferredDefault {
//        let d = DeferredDefault()
//        next.append(d)
//        _error(constrainOneVoid(fn))
//        return d
//    }
//
//    func then(fn: () -> ()) -> DeferredContinuing {
//        let d = DeferredContinuing()
//        next.append(d)
//        _then(constrainVoidVoid(fn))
//        return d
//    }
//}


// Exmaples and inline tests follow

// Default, no args errback and callback
//let d: DeferredVoid = Deferred()
//
//d.then {
//    print("Default Then")
//    let a = 1
//}
//
//d.callback([])
//
//d.error { r in
//    print("DefaultError")
//    let b = 2
//}
//
//d.errback(["Asdf"])


// Default chaining
//let d: DeferredVoid = Deferred()
//
//d.then {
//    let a = 1
//}.then {
//    let b = 2
//}
//
//d.callback([])
//
//d.error { e in
//    let a = 3
//}.error { e in
//    let b = 4
//}
//
//d.errback(["Asdf"])


// Lazy callbacks- immediately fire callback handler if the chain has already been called back
//var d: DeferredVoid = Deferred()
//d.callback([])
//
//d.then {
//    let a = 1
//}.then {
//    let b = 2
//}
//
//d = Deferred()
//d.errback([""])
//
//d.error { e in
//    let a = 1
//}.error { e in
//    let b = 2
//}



// Waiting for an internal deferred to resolve
//var d: DeferredChain = Deferred()
//let f = Deferred() // Some operation that returns a deferred, mocked
//
//f.then {
//    let a = 2
//    print(a)
//}
//
//d.then {
//    let a = 1
//    print(a)
//    return f
//}.then {
//    let b = 3
//    print(b)
//}
//
//d.callback([])
//f.callback([])



// Chain the results of one deferred to another in a type safe way
// Can't really mix these very well with the deferred chains yet
//var d: DeferredValueChain = Deferred()
//
//d.then {
//    return "Hello"
//}.then { s in
//    print("Have string \(s)!")
//    print("I dont return anything!")
//}.then {
//    print("Done")
//}
//
//d.callback([])


//let d = DeferredParams<String>()
//
//d.then { s in
//    print("Have s!")
//}.then {
//    let b = 2
//}
//
//d.callback(["asdf"])
















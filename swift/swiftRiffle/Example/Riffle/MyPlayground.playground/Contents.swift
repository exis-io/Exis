
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
extension Int : BaseConvertible { }
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
    return BaseClosure(fn: fn).setCurry { a in
        if A.self == Void.self {
            fn(() as! A)
        } else {
            fn(a[0] as! A)
        }
        
        return []
    }
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

func accept<A, B>(fn: A -> B)  -> BaseClosure<A, B> {
    return BaseClosure(fn: fn)
}



struct DeferredData {
    // The chain of next deferreds
    var next: [AbstractDeferred] = []
    
    // Automatically invoke callbacks and errbacks if not nil when given arguments
    var callbackArgs: [AnyObject]?
    var errbackArgs: [AnyObject]?
    
    // If an invocation has already occured then the args properties are already set
    // We should invoke immediately
    var _callback: AnyClosureType? {
        didSet { if let a = callbackArgs { invokeCallback(a) } }
    }
    
    var _errback: AnyClosureType? {
        didSet { if let a = errbackArgs { invokeErrback(a) } }
    }
    
    // Fire the function stored as callback/errback and inform the next deferred of the results
    mutating func invokeCallback(args: [AnyObject]) {
        callbackArgs = args
        var ret: [AnyObject] = []
        if let cb = _callback { ret = cb.call(args) }
        for n in next { n.callback(ret) }
    }
    
    mutating func invokeErrback(args: [AnyObject]) {
        errbackArgs = args
        if let eb = _errback { eb.call(args) }
        for n in next { n.errback(args) }
    }
}

class AbstractDeferred {
    // Automatically invoke callbacks and errbacks if not nil when given arguments
    var callbackArgs: [AnyObject]?
    var errbackArgs: [AnyObject]?
    
    // If an invocation has already occured then the args properties are already set
    // We should invoke immediately
    var _callback: AnyClosureType?
    var _errback: AnyClosureType?
    
    // The next link in the chain
    var next: [AbstractDeferred] = []
    
    
    func _then<T: AbstractDeferred>(fn: AnyClosureType, nextDeferred: T) -> T {
        next.append(nextDeferred)
        if let a = callbackArgs { callback(a) }
        _callback = fn
        return nextDeferred
    }
    
    func _error<T: AbstractDeferred>(fn: AnyClosureType, nextDeferred: T) -> T {
        next.append(nextDeferred)
        _errback = fn
        if let a = errbackArgs { errback(a) }
        return nextDeferred
    }
    
    func callback(args: [AnyObject]) {
        callbackArgs = args
        var ret: [AnyObject] = []
        if let cb = _callback { ret = cb.call(args) }
        for n in next { n.callback(ret) }
    }
    
    func errback(args: [AnyObject]) {
        errbackArgs = args
        if let eb = _errback { eb.call(args) }
        for n in next { n.errback(args) }
    }
    
    func error(fn: String -> ()) -> Deferred<Void> {
        return _error(constrainOneVoid(fn), nextDeferred: Deferred<Void>())
    }
}


class Deferred<A>: AbstractDeferred {
    func then(fn: A -> ())  -> Deferred<Void> {
        return _then(constrainOneVoid(fn), nextDeferred: Deferred<Void>())
    }
    
    func chain(fn: () -> Deferred) -> Deferred<Void> {
        let next = Deferred<Void>()
        
        _callback = constrainVoidVoid {
            fn().next.append(next)
        }
        
        return next
    }
    
    func chain<T: CN>(fn: A -> Deferred<T>)  -> Deferred<T> {
        let next = Deferred<T>()
        
        _callback = constrainOneVoid { (a: A) in
            fn(a).then { s in
                next.callback([s as! AnyObject])
            }.error { s in
                next.errback([s])
            }
        }
        
        return next
    }
}


// Exmaples and inline tests follow

// Default, no args errback and callback
_ = {
    let d = Deferred<Void>()
    
    d.then {
        print("Default Then")
        let a = 1
    }
    
    d.callback([])
    
    d.error { r in
        print("DefaultError")
        let b = 2
    }
    
    d.errback(["Asdf"])
    }()


// Default chaining
_ = {
    let d = Deferred<Void>()
    
    d.then {
        let a = 1
    }.then {
        let b = 2
    }
    
    d.callback([])
    
    d.error { e in
        let a = 3
    }.error { e in
        let b = 4
    }
    
    d.errback([""])
    }()


// Lazy callbacks- immediately fire callback handler if the chain has already been called back
_ = {
    var d = Deferred<Void>()
    d.callback([])
    
    d.then {
        let a = 1
        }.then {
            let b = 2
    }
    
    d.errback([""])
    
    d.error { e in
        let a = 1
    }.error { e in
        let b = 2
    }
    }()


 // Waiting for an internal deferred to resolve
 _ = {
     var d = Deferred<Void>()
     let f = Deferred<Void>()
     
     // This is pretty close, but not quite there
     f.then { s in
        print(12)
     }
     
     d.chain {
        print(11)
        return f
     }.then {
        print(13)
     }
     
     d.callback([])
     f.callback(["Hello"])
 }()

 
 // Param constraints
 _ = {
     var d = Deferred<()>()
     var e = Deferred<String>()
     
     d.chain { () -> Deferred<String> in
        let a = 1
        return e
     }.then { s in
        print("Have", s)
        let a = 2
     }
     
    d.callback([1])
    e.callback(["Done!"])
 }()
*/

// A Mix of the above two. Given a deferred that returns value in some known
// type, returning that deferred should chain the following then as a callback of the appropriate type
_ = {
    var d = Deferred<Void>()
    let f = Deferred<String>()

    d.chain { () -> Deferred<String> in
        print(1)
        return f
    }.then { s in
        print(s)
        print(2)
    }.then {
        print(3) // I dont take any args, since the block above me didnt reutn a deferred
    }.error { err in
        print("Error: \(err)")
    }

    d.callback([])
    // f.callback(["Hello"])
    f.errback(["early termination"])
}()


// Returning a nested deferred twice
_ = {
    var d = Deferred<Void>()
    let f = Deferred<String>()
    let c = Deferred<Bool>()

    d.chain { () -> Deferred<String> in
        print(1)
        return f
    }.chain { str -> Deferred<Bool> in
        print(2, str)
        return c
    }.then { bool in
        print(3, bool)
    }.error { err in
        print("Error: \(err)")
    }

    // Comment out lines below and make sure the prints do or dont show up in order
    d.callback([])
    f.callback(["Hello"])
    c.callback([true])
    
    // f.errback(["early termination"])
}()





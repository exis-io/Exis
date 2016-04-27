
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

func accept<A, B>(fn: A -> B)  -> BaseClosure<A, B> {
    return BaseClosure(fn: fn)
}

accept() {
    print("hi")
}



protocol BetterDeferredType {
    func callback(args: [AnyObject])
    func errback(args: [AnyObject])
}

struct DeferredData {
    // The chain of next deferreds
    var next: [BetterDeferredType] = []
    
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

class AbstractDeferred: BetterDeferredType {
    var data = DeferredData()
    
    func _then<T: BetterDeferredType>(fn: AnyClosureType, next: T) -> T {
        data.next.append(next)
        data._callback = fn
        return next
    }
    
    func _error<T: BetterDeferredType>(fn: AnyClosureType, next: T) -> T {
        data.next.append(next)
        data._errback = fn
        return next
    }
    
    func callback(args: [AnyObject]) {
        data.invokeCallback(args)
    }
    
    func errback(args: [AnyObject]) {
        data.invokeErrback(args)
    }
}

class BasicDeferred: AbstractDeferred {
    func then(fn: () -> ())  -> BasicDeferred {
        return _then(constrainVoidVoid(fn), next: BasicDeferred())
    }
    
    func error(fn: String -> ())  -> BasicDeferred {
        return _error(constrainOneVoid(fn), next: BasicDeferred())
    }
}


class ChainedDeferred: AbstractDeferred {
    func then<A, B>(fn: A -> B)  -> TypedDeferred<A> {
        return _then(accept(fn), next: TypedDeferred<A>())
    }
    
    func error(fn: String -> ())  -> ChainedDeferred {
        return _error(constrainOneVoid(fn), next: ChainedDeferred())
    }
    
    override func callback(args: [AnyObject]) {
        print("Called with \(args)")
        super.callback(args)
    }
}

// A deferred where the then block *must* accept some value A
class TypedDeferred<A: CN>: AbstractDeferred {
    func then(fn: A -> ())  -> TypedDeferred<A> {
        return _then(constrainOneVoid(fn), next: TypedDeferred<A>())
    }
    
    override func callback(args: [AnyObject]) {
        print("Called with \(args)")
        super.callback(args)
    }
}

// Exmaples and inline tests follow


// Default, no args errback and callback
//_ = {
//    let d = BasicDeferred()
//
//    d.then {
//        print("Default Then")
//        let a = 1
//    }
//
//    d.callback([])
//
//    d.error { r in
//        print("DefaultError")
//        let b = 2
//    }
//
//    d.errback(["Asdf"])
//}()


//// Default chaining
//_ = {
//    let d = BasicDeferred()
//
//    d.then {
//        let a = 1
//    }.then {
//        let b = 2
//    }
//
//    d.callback([])
//
//    d.error { e in
//        let a = 3
//    }.error { e in
//        let b = 4
//    }
//
//    d.errback([""])
//}()


//// Lazy callbacks- immediately fire callback handler if the chain has already been called back
//_ = {
//    var d = BasicDeferred()
//    d.callback([])
//
//    d.then {
//        let a = 1
//    }.then {
//        let b = 2
//    }
//
//    d.errback([""])
//
//    d.error { e in
//        let a = 1
//    }.error { e in
//        let b = 2
//    }
//}()


// Waiting for an internal deferred to resolve
//_ = {
//    var d = ChainedDeferred()
//    let f = BasicDeferred() // Some operation that returns a deferred, mocked
//
//    f.then {
//        let a = 2
//        print(a)
//    }
//
//    d.then {
//        let a = 1
//        print(a)
//        return f
//    }.then {
//        let b = 3
//        print(b)
//    }
//
//    d.callback([])
//    f.callback([])
//}()


// Param constraints
_ = {
    var d = TypedDeferred<Int>()

    d.then { a in
        print("Have a: \(a)")
        let a = 1
    }

    d.callback([1])
}()


// Chain the results of one deferred to another in a type safe way
// Can't really mix these very well with the deferred chains yet
//var d: DeferredValueChain = BaseDeferred()
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


//let d = DeferredParams<Int>()
//
//d.then { s in
//    print("Have \(s)")
//}.then {
//    let b = 2
//}
//
//d.callback([1])



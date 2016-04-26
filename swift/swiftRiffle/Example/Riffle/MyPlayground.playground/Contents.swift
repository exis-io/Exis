
import Foundation


protocol Convertible {}
typealias CN = Convertible

extension String : Convertible {}
extension Bool : Convertible {}


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
    let curried: [AnyObject] -> [AnyObject]
    func call(args: [AnyObject]) -> [AnyObject] { return curried(args) }
    
    init(fn: A -> B, curry: [AnyObject] -> [AnyObject]) {
        handler = fn
        curried = curry
    }
}

// Generates constrained and concrete closures. Conversion is done here
func constrainFunction<A: CN, B: CN, C: CN>(fn: (A, B) -> C)  -> BaseClosure<(A, B), C> {
    return BaseClosure(fn: fn, curry: { a in return [fn(a[0] as! A, a[1] as! B) as! AnyObject]})
}

func constrainFunction(fn: () -> ())  -> BaseClosure<Void, Void> {
    return BaseClosure(fn: fn, curry: { a in return [fn() as! AnyObject]})
}

//func constrainFunction<A: CN>(fn: A -> ())   {
//    BaseClosure(fn: fn, curry: { a in return [fn() as! AnyObject]})
//}


let d = constrainFunction() { (a: String, b: Bool) -> String in
    print("Hello!")
    return "Done"
}



protocol Deferred {
    associatedtype NextDeferred
    
    var next: NextDeferred { get }
    var fired: Bool { get set }
    
    var callbackArgs: [AnyObject]? { get set }
    var errbackArgs: [AnyObject]? { get set }
    
    var _callback: AnyClosureType? { get set }
    var _errback: AnyClosureType? { get set }
    
    func callback(args: [AnyObject])
    func errback(args: [AnyObject])
}

// The generic kind is the type of the next deferred
class AbstractDeferred: Deferred {
    var next: AbstractDeferred?
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
        if let nextDeferred = next { nextDeferred.callback(ret!) }
    }
    
    func errback(args: [AnyObject]) {
        errbackArgs = args
        fired = true
        let ret = _errback?.call(args)
        if let nextDeferred = next { nextDeferred.errback(ret!) }
    }
}

class BaseDeferred<A, B>: AbstractDeferred {
    func _then(fn: BaseClosure<A, B>) {
        _callback = fn
    }
    
    func _error(fn: BaseClosure<A, B>) {
        _errback = fn
    }
}

// A deferred that doesn't take arguments
protocol DeferredZero {
    func then(fn: () -> ())
}

protocol DeferredBaseError {
    func error(fn: (String) -> ())
}

class _DeferredZero: BaseDeferred<Void, Void> {}

extension _DeferredZero: DeferredZero {
    func then(fn: () -> ())  {
        _then(constrainFunction(fn))
    }
}

extension _DeferredZero: DeferredBaseError {
    func error(fn: (String) -> ())  {
//        _error(BaseClosure<String, Void>(fn: fn, curry: { a in return [] }))
//        _error(constrainFunction(fn))
    }
}

//protocol FunctionType {
//    associatedtype ParameterTypes
//    associatedtype ReturnTypes
//    
//    var handler: ParameterTypes -> ReturnTypes { get set }
//    func invoke(args: ParameterTypes) -> ReturnTypes
//}
//
//
//class AbstractClosure<P, R>: FunctionType {
//    var handler: P -> R
//    init(fn: P -> R) { handler = fn }
//    func invoke(args: P) -> R { return handler(args) }
//    
//    func parameterTypes() -> P.Type { return P.self }
//    func returnTypes() -> R.Type { return R.self }
//}
//
//
//// How to use AbstractClosure
//let t = AbstractClosure() { (a: String, b: String, c: String) -> String in return "asdf" }
//let p = AbstractClosure() { (c: Int) in }
//
//t.invoke(("asdf", "asdf", "asdf"))
//t.parameterTypes()
//t.returnTypes()
//
//
//
//// Accepts any function. Now just to constrain the types...
//func accept<A, B>(fn: A -> B) {
//    let closure = AbstractClosure(fn: fn)
//    print("Have closure: \(closure)")
//}
//
//accept() { (a: String) in }
//accept() { (b: Bool, c: Bool) -> String in return "asdf" }



//protocol ClosureType {
//    associatedtype ParameterTypes
//    associatedtype ReturnTypes
//    
//    var handler: ParameterTypes -> ReturnTypes { get set }
//    func invoke(args: ParameterTypes) -> ReturnTypes
//}
//
//
//class AbstractClosure<P, R>: ClosureType {
//    var handler: P -> R
//    init(fn: P -> R) { handler = fn }
//    func invoke(args: P) -> R { return handler(args) }
//    
//    func parameterTypes() -> P.Type { return P.self }
//    func returnTypes() -> R.Type { return R.self }
//}
//
//
//// How to use AbstractClosure
//let t = AbstractClosure() { (a: String, b: String, c: String) -> String in return "asdf" }
//let p = AbstractClosure() { (c: Int) in }
//
//t.invoke(("asdf", "asdf", "asdf"))
//t.parameterTypes()
//t.returnTypes()
//
//
//
//// Accepts any function. Now just to constrain the types...
//func accept<A, B>(fn: A -> B) {
//    let closure = AbstractClosure(fn: fn)
//    print("Have closure: \(closure)")
//}
//
//accept() { (a: String) in }
//accept() { (b: Bool, c: Bool) -> String in return "asdf" }
//
//









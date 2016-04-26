
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
struct BaseClosure<A, B>: AnyClosureType, ClosureType {
    let handler: A -> B
    let curried: [AnyObject] -> [AnyObject]
    func call(args: [AnyObject]) -> [AnyObject] { return curried(args) }
}

// Generates constrained and concrete closures. Conversion is done here
func generateConstrainedFunction<A: CN, B: CN, C: CN>(fn: (A, B) -> C)  -> BaseClosure<(A, B), C> {
    return BaseClosure(handler: fn, curried: { a in return [fn(a[0] as! A, a[1] as! B) as! AnyObject]})
}

let d = generateConstrainedFunction() { (a: String, b: Bool) -> String in
    print("Hello!")
    return "Done"
}



protocol BaseDeferred {
    associatedtype NextDeferred
    
    var next: NextDeferred { get }
    var fired: Bool { get set }
    
    var callbackArgs: [AnyObject]? { get set }
    var errbackArgs: [AnyObject]? { get set }
    
    mutating func callback(args: [AnyObject])
    mutating func errback(args: [AnyObject])
}

// The generic kind is the type of the next deferred
struct Deferred<T>: BaseDeferred {
    var next: T
    var fired: Bool
    
    var callbackArgs: [AnyObject]?
    var errbackArgs: [AnyObject]?
    
    
    mutating func callback(args: [AnyObject]) {
        // apply(args, &callbackArgs, t.callback, t.err)
        callbackArgs = args
    }
    
    mutating func errback(args: [AnyObject]) {
        errbackArgs = args
    }
    
    mutating func apply(args: [AnyObject], inout target: [AnyObject]?, handler: [AnyObject] -> [AnyObject], then: ([AnyObject] -> [AnyObject])?) {
        target = args
        fired = true
        let ret = handler(args)
        if let t = then { t(ret) }
    }
}


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









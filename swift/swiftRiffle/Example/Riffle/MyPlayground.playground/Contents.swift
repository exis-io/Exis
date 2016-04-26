
import Foundation


protocol Convertible {}
typealias CN = Convertible

extension String : Convertible {}
extension Bool : Convertible {}


protocol AnyFunction {
    func call(args: [AnyObject]) -> [AnyObject]
}

protocol FunctionType {
    associatedtype ParameterTypes
    associatedtype ReturnTypes
    var handler: ParameterTypes -> ReturnTypes { get set }
}

struct UnconstrainedFunction<A, B>: FunctionType {
    var handler: A -> B
    func invoke(args: A) -> B? { return handler(args) }
}

// Concrete and constrained. Might as well use the method below, though, and override it
struct ConstrainedFunction: AnyFunction {
    var curriedHandler: ([AnyObject]) -> ([AnyObject])

    func call(args: [AnyObject]) -> [AnyObject] {
        return curriedHandler(args)
    }
}

func generateConstrainedFunction<A: CN, B: CN, C: CN>(fn: (A, B) -> C)  {
    UnconstrainedFunction<(A, B), C>(handler: fn)
    
    ConstrainedFunction() { a in return fn(a[0] as! A, a[1] as! B) }
}

generateConstrainedFunction() { (a: String, b: Bool) -> String in
    print("Hello!")
    return ""
}


















protocol ClosureType {
    associatedtype ParameterTypes
    associatedtype ReturnTypes
    
    var handler: ParameterTypes -> ReturnTypes { get set }
    func invoke(args: ParameterTypes) -> ReturnTypes
}


class AbstractClosure<P, R>: ClosureType {
    var handler: P -> R
    init(fn: P -> R) { handler = fn }
    func invoke(args: P) -> R { return handler(args) }
    
    func parameterTypes() -> P.Type { return P.self }
    func returnTypes() -> R.Type { return R.self }
}


// How to use AbstractClosure
let t = AbstractClosure() { (a: String, b: String, c: String) -> String in return "asdf" }
let p = AbstractClosure() { (c: Int) in }

t.invoke(("asdf", "asdf", "asdf"))
t.parameterTypes()
t.returnTypes()



// Accepts any function. Now just to constrain the types...
func accept<A, B>(fn: A -> B) {
    let closure = AbstractClosure(fn: fn)
    print("Have closure: \(closure)")
}

accept() { (a: String) in }
accept() { (b: Bool, c: Bool) -> String in return "asdf" }











//
//  AnyFunction.swift
//  Pods
//
//  Created by damouse on 4/26/16.
//
//  Generic wrappers that allow "AnyFunction" to be accepted and constrained by type and number of parameters

import Foundation


//protocol Convertible {
//    // Convert the given argument to this type
//    static func to<T: AnyObject>(from: T) -> Self
//    
//    // Get a serializable value from this type
//    func from() -> AnyObject
//}
//
//typealias CN = Convertible
//
//protocol BaseConvertible: Convertible {}
//
//extension BaseConvertible {
//    static func to<T: AnyObject>(from: T) -> Self { return from as! Self }
//    func from() -> AnyObject { return self as! AnyObject }
//}
//
//typealias CN = Convertible
//
//extension String : BaseConvertible { }
//extension Bool : BaseConvertible { }

protocol AnyFunction {
    func call(args: [Any]) -> [Any]
}

protocol FunctionType {
    associatedtype ParameterTypes
    associatedtype ReturnTypes
    var handler: ParameterTypes -> ReturnTypes { get }
}

// Concrete and invokable. Doesn't care about types
class SomeFunction<A, B>: FunctionType, AnyFunction {
    let handler: A -> B
    var curried: ([Any] -> [Any])!
    
    // For some reason the generic constraints aren't forwarded correctly when
    // the curried function is passed along, so it gets its own method below
    // You must call setCurry immediately after init!
    init(fn: A -> B) {
        handler = fn
    }
    
    func call(args: [Any]) -> [Any] {
        return curried(args)
    }
    
    func setCurry(fn: [Any] -> [Any]) -> Self {
        curried = fn
        return self
    }
}

// Generates constrained concrete closures. Some of these methods have different names
// instead of overloads to cases where non-generic overrides get called instead of the generic ones
func constrainVoidVoid(fn: () -> ())  -> SomeFunction<Void, Void> {
    return SomeFunction(fn: fn).setCurry { a in fn(); return [] }
}

func constrainOneVoid<A>(fn: (A) -> ()) -> SomeFunction<A, Void> {
    return SomeFunction(fn: fn).setCurry { a in fn(a[0] as! A); return [] }
}

func constrainVoidOne<A>(fn: () -> A) -> SomeFunction<Void, A> {
    return SomeFunction(fn: fn).setCurry { a in [fn() as! Any] }
}

func constrain<A: PR, B: PR, C: PR>(fn: (A, B) -> C)  -> SomeFunction<(A, B), C> {
    return SomeFunction(fn: fn).setCurry { a in return [fn(A.self <- a[0], B.self <- a[1]) as! Any]}
}

func constrain<A: PR, B: PR>(fn: A -> B)  -> SomeFunction<A, B> {
    return SomeFunction(fn: fn).setCurry { a in return [fn(A.self <- a[0]) as! Any]}
}





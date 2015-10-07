//
//  Cumin.swift
//  Pods
//
//  Created by Mickey Barboi on 10/6/15.
//
//

/*
    Cumin allows for type-safe deferred method evaluation
    through currying. Not sure how to make it play without variadic generics, though there might be a way

    TODO:
        throw a well known error on miscast
        throw a well known error if args size doesn't match
        hold method weakly, dont call if deallocd EDIT: actually, dont hold the method at all-- evaluate at execution time

    NOTES:
        Stupid generics.
        Could be useful http://stackoverflow.com/questions/27591366/swift-generic-type-cast

    Works to detect an array, but from there...
    if t is ArrayProtocol.Type {
*/

import Foundation
import Mantle

// Hack to get the arrays to detect
protocol ArrayProtocol{}
extension Array: ArrayProtocol {}


// MARK: Converters
public func convert <A, T>(a:A?, _ t:T.Type) -> T? {
    // Attempts to convert the given argument to the expected type
    
    // If the type casts out the box it is most likely the intended type
    if let z = a as? T {
        return z
    }
    
    // Primitive conversion
    // TODO: check to make sure the passed type is valid: a.dynamicType == NSNumber.self
    switch t {
    case is Int.Type:
        return Int(a as! NSNumber) as? T
        
    case is Double.Type:
        return Double(a as! NSNumber) as? T
        
    case is Float.Type:
        return Float(a as! NSNumber) as? T
        
    case is String.Type:
        return String(a) as? T
        
    default: break
    }

    // Attempt a model conversion
    if let Klass = t as? RiffleModel.Type {
        return (MTLJSONAdapter.modelOfClass(Klass, fromJSONDictionary: a as! [NSObject:AnyObject]) as! T)
    }
    
    // TODO: Boolean, dicts,
    
    // Collections, applied recursively
    if let source = a as? NSArray {
        switch t {
        case is [String].Type:
            return (source.map { convert($0, String.self)! } as! T)
        default:
            print("aww")
        }
    }
    
    return nil
}


// Converter operator. Attempts to convert the object on the right to the type given on the left
// Just here to make the cumin conversion functions just the smallest bit clearer
infix operator < {
    associativity right
    precedence 155
}

func <<T> (t:T.Type, object: AnyObject) -> T {
    return convert(object, t)!
}


//MARK: Cumin Overloads
public func cumin(fn: () -> ()) -> ([AnyObject]) -> () {
    return { (a: [AnyObject]) in fn() }
}

public func cumin<A>(fn: (A) -> ()) -> ([AnyObject]) -> () {
    return { (a: [AnyObject]) in fn(A.self < a[0]) }
}

public func cumin<A, B>(fn: (A, B) -> ()) -> ([AnyObject]) -> () {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1]) }
}

public func cumin<A, B, C>(fn: (A, B, C) -> ()) -> ([AnyObject]) -> () {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1], C.self < a[2]) }
}

public func cumin<A, B, C, D>(fn: (A, B, C, D) -> ()) -> ([AnyObject]) -> () {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1], C.self < a[2], D.self < a[3]) }
}

public func cumin<A, B, C, D, E>(fn: (A, B, C, D, E) -> ()) -> ([AnyObject]) -> () {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1], C.self < a[2], D.self < a[3], E.self < a[4]) }
}

public func cumin<R>(fn: () -> (R)) -> ([AnyObject]) -> (R) {
    return { (a: [AnyObject]) in fn() }
}

public func cumin<A, R>(fn: (A) -> (R)) -> ([AnyObject]) -> (R) {
    return { (a: [AnyObject]) in fn(A.self < a[0]) }
}

public func cumin<A, B, R>(fn: (A, B) -> (R)) -> ([AnyObject]) -> (R) {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1]) }
}

public func cumin<A, B, C, R>(fn: (A, B, C) -> (R)) -> ([AnyObject]) -> (R) {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1], C.self < a[2]) }
}

public func cumin<A, B, C, D, R>(fn: (A, B, C, D) -> (R)) -> ([AnyObject]) -> (R) {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1], C.self < a[2], D.self < a[3]) }
}

public func cumin<A, B, C, D, E, R>(fn: (A, B, C, D, E) -> (R)) -> ([AnyObject]) -> (R) {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1], C.self < a[2], D.self < a[3], E.self < a[4]) }
}

public func cumin<R, S>(fn: () -> (R, S)) -> ([AnyObject]) -> (R, S) {
    return { (a: [AnyObject]) in fn() }
}

public func cumin<A, R, S>(fn: (A) -> (R, S)) -> ([AnyObject]) -> (R, S) {
    return { (a: [AnyObject]) in fn(A.self < a[0]) }
}

public func cumin<A, B, R, S>(fn: (A, B) -> (R, S)) -> ([AnyObject]) -> (R, S) {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1]) }
}

public func cumin<A, B, C, R, S>(fn: (A, B, C) -> (R, S)) -> ([AnyObject]) -> (R, S) {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1], C.self < a[2]) }
}

public func cumin<A, B, C, D, R, S>(fn: (A, B, C, D) -> (R, S)) -> ([AnyObject]) -> (R, S) {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1], C.self < a[2], D.self < a[3]) }
}

public func cumin<A, B, C, D, E, R, S>(fn: (A, B, C, D, E) -> (R, S)) -> ([AnyObject]) -> (R, S) {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1], C.self < a[2], D.self < a[3], E.self < a[4]) }
}

public func cumin<R, S, T>(fn: () -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
    return { (a: [AnyObject]) in fn() }
}

public func cumin<A, R, S, T>(fn: (A) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
    return { (a: [AnyObject]) in fn(A.self < a[0]) }
}

public func cumin<A, B, R, S, T>(fn: (A, B) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1]) }
}

public func cumin<A, B, C, R, S, T>(fn: (A, B, C) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1], C.self < a[2]) }
}

public func cumin<A, B, C, D, R, S, T>(fn: (A, B, C, D) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1], C.self < a[2], D.self < a[3]) }
}

public func cumin<A, B, C, D, E, R, S, T>(fn: (A, B, C, D, E) -> (R, S, T)) -> ([AnyObject]) -> (R, S, T) {
    return { (a: [AnyObject]) in fn(A.self < a[0], B.self < a[1], C.self < a[2], D.self < a[3], E.self < a[4]) }
}


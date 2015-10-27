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

func convert<A: AnyObject, T: Cuminicable>(a: A?, _ t: T.Type) -> T? {
    if let x = a {
        return t.convert(x) as? T
    }
    
    return nil
}

func convert<A: AnyObject, T: CollectionType where T.Generator.Element: Cuminicable>(a: A?, _ t: T.Type) -> T? {
    // Attempt to convert an array of arbitrary elements to collection of Cuminicable elements. The sequence is passed
    // as a type of these elements as understood from the method signature where they're declared.
    
    // The expected sequence element type
    // Not implemented: recursive handling of nested data structures
    let CuminicableElement = T.Generator.Element.self
    print(CuminicableElement)
    
    // Attempt to process the incoming parameters as an array
    if let x = a as? NSArray {
        var ret: [T.Generator.Element] = []
        
        for e in x {
            if let converted = CuminicableElement.convert(e) as? T.Generator.Element {
                ret.append(converted)
            } else {
                // If a single one of the casts fail, stop processing the collection.
                // This behavior may not always be expected since it does not allow collections of optionals
                
                // TODO: Print out or return some flavor of log here?
                return nil
            }
        }
        
        return ret as? T
    }
    
    // Can cover arrays here, too
    
    return nil
}

public func serialize(args: [AnyObject]) -> [AnyObject] {
    // Converts types for serialization, mostly RiffleModels
    var ret: [AnyObject] = []
    
    for a in args {
        if let object = a as? RiffleModel {
            ret.append(MTLJSONAdapter.JSONDictionaryFromModel(object))
        } else {
            ret.append(a)
        }
    }
    
    return ret
}

// Converter operator. Attempts to convert the object on the right to the type given on the left
// Just here to make the cumin conversion functions just the smallest bit clearer
infix operator <- {
associativity right
precedence 155
}

func <- <T: CN> (t:T.Type, object: AnyObject) -> T {
    let a = convert(object, t)
    // This would be an exxcellent place to catch cumin errors
    // Throwing is likely the easiest way to deal with them
    
    return a!
}


// MARK: Deprecated V1 Cumin
/*
public func convert <A, T>(a:A, _ t:T.Type) -> T? {
// Attempts to convert the given argument to the expected type

// If the type casts out the box it is most likely the intended type
if let z = a as? T {
return z
}

// Begin the OSX bug
if "\(T.self)" == "Int" {
return unsafeBitCast(Int(a as! NSNumber), T.self)
}

if "\(T.self)" == "String" {
return unsafeBitCast(String(a as! NSString), T.self)
}

// Primitive conversion
// TODO: check to make sure the passed type is valid: a.dynamicType == NSNumber.self

switch t {
case is Int:
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
// Going to have to apply the osx bug fix here too... string checking required
if let source = a as? NSArray {

// If we're reciving an array and its empty, it doesn't matter what you expected to get back (right?)
// Alternatively, this could just be an error, in which case you're screwed
if source.count == 0 {
return [] as! T
}

let element = source.firstObject!
print(element)

if let r = element as? RiffleModel.Type {
print("ISARIFFLEMODEL")
}

switch t {
case is [String].Type:
return (source.map { convert($0, String.self)! } as! T)
case is [Bool].Type:
return (source.map { convert($0, Bool.self)! } as! T)
case is [Int].Type:
return (source.map { convert($0, Int.self)! } as! T)
case is [Float].Type:
return (source.map { convert($0, Float.self)! } as! T)
case is [RiffleModel].Type:
return (source.map { convert($0, RiffleModel.self)! } as! T)
default:
print("UNIMPLEMENTED COLLECTION: \(source.dynamicType)")
//            print(source)
print(t)

if let Klass = t as? [RiffleModel].Type {
print("Able to extrace the programmic types: Klass")
}
}
}

return nil
}


public func serialize(args: [AnyObject]) -> [AnyObject] {
// Converts types for serialization, mostly RiffleModels
var ret: [AnyObject] = []

for a in args {
if let object = a as? RiffleModel {
ret.append(MTLJSONAdapter.JSONDictionaryFromModel(object))
} else {
ret.append(a)
}
}

return ret
}
*/

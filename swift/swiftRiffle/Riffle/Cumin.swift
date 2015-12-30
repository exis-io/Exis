//
//  Cumin.swift
//  RiffleTest
//
//  Created by damouse on 12/28/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation

public enum CuminError: ErrorType {
    case InvalidTypes(String, String)
    case InvalidNumberParams(Int, Int)
}

func apc(arr: [AnyObject], _ len: Int) throws {
    // Assert Parameter Count
    // make sure the passed array has exactly the expected number of arguments
    if arr.count != len {
        throw CuminError.InvalidNumberParams(arr.count, len)
    }
}

func convert<A: AnyObject, T: Cuminicable>(a: A?, _ t: T.Type) throws -> T {
    //print("Expecting: \(T.self)")
    //print("Incoming: \(a)")
    
    if let x = a {
        let ret = t.convert(x)
        
        // If nothing was returned then no possible conversion was possible
        guard let castResult = ret else {
            throw CuminError.InvalidTypes("\(T.self)", "\(a)")
        }
        
        if let finalResult = castResult as? T {
            return finalResult
        }
        
        // Catch the OSX error as a last resort: on OSX the type pointers point to different things because of
        // "embedded swift code..." and the library being imported twice
        // If we've gotten here the normal things aren't going to work
        if let bibble = t.brutalize(castResult, T.self) as? T{
            return bibble
        }
    }
    
    throw CuminError.InvalidTypes("\(T.self)", "\(a)")
}

func convert<A: AnyObject, T: CollectionType where T.Generator.Element: Cuminicable>(a: A?, _ t: T.Type) throws -> T {
    // Attempt to convert an array of arbitrary elements to collection of Cuminicable elements. The sequence is passed
    // as a type of these elements as understood from the method signature where they're declared.
    
    // The expected sequence element type
    // Not implemented: recursive handling of nested data structures-- this is very important!
    
    //print("Incoming Data: \(a)")
    //print("Expected Type: \(T.self)")
    
    // Attempt to process the incoming parameters as an array
    if let x = a as? NSArray {
        var ret: [T.Generator.Element] = []
        
        for e in x {
            ret.append(try T.Generator.Element.self <- e)
        }
        
        if let cast = ret as? T {
            //print("Returning Cast: \(cast)")
            return cast
        }
        
        // Emergency time-- have to cover the OSX cases here
        return unsafeBitCast(ret, T.self)
    }
    
    // If this is an array and nothing was passed in return empty array
    let ret: [T.Generator.Element] = []
    return ret as! T
    
    // Cover dicts and nesting here!
    
    //throw CuminError.InvalidTypes("\(T.self)", "\(a)")
}

func serialize(convert: AnyObject) throws -> [AnyObject] {
    // Converts types for serialization, mostly Models
    var ret: [AnyObject] = []
    var args: [AnyObject] = []
    
    if let autoArray = convert as? [AnyObject] {
        args = autoArray
    } else {
        args = [convert]
    }
    
    for a in args {
        if let object = a as? Model {
            // let converted = try MTLJSONAdapter.JSONDictionaryFromModel(object, error: ())
            // ret.append(converted)
        } else if let objects = a as? [Model] {
            // let converted = try MTLJSONAdapter.JSONArrayFromModels(objects, error: ())
            // ret.append(converted)
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

func <- <T: CN> (t:T.Type, object: AnyObject) throws -> T {
    return try convert(object, t)
}

func <- <T: CollectionType where T.Generator.Element: CN> (t:T.Type, object: AnyObject) throws -> T {
    return try convert(object, t)
}


public protocol Cuminicable {
    static func convert(object: AnyObject) -> Cuminicable?
    
    // Assume the object passed in is of the same type as this object
    // Apply an unsafebitcast to the object to make it play nicely with the return types
    // Required on OSX console apps since the app and the framework link against different versions of swift stdlib
    static func brutalize<T: Cuminicable>(object: Cuminicable, _ t: T.Type) -> Cuminicable?
}


// Used to shorten Generic Wrappers
public typealias CN = Cuminicable
public typealias CL = CollectionType


// Attempting to make a catch all method for the brutal casts
func _brutalize<A, T: Cuminicable>(object: Cuminicable, _ expected: A.Type, _ t: T.Type) -> Cuminicable? {
    if let x = object as? A.Type {
        return unsafeBitCast(x, T.self)
    }
    
    return nil
}

extension Int: Cuminicable {
    public static func convert(object: AnyObject) -> Cuminicable? {
        if let x = object as? Int {
            return x
        }
        
        if let x = object as? String {
            return Int(x)
        }
        
        return nil
    }
    
    public static func brutalize<T: Cuminicable>(object: Cuminicable, _ t: T.Type) -> Cuminicable? {
        if let x = object as? Int {
            return unsafeBitCast(x, T.self)
        }
        
        return nil
    }
}

extension String: Cuminicable {
    public static func convert(object: AnyObject) -> Cuminicable? {
        
        if let x = object as? String {
            return x
        }
        
        if let x = object as? Int {
            return String(x)
        }
        
        return nil
    }
    
    public static func brutalize<T: Cuminicable>(object: Cuminicable, _ t: T.Type) -> Cuminicable? {
        if let x = object as? String {
            return unsafeBitCast(x, T.self)
        }
        
        return nil
    }
}

extension Double: Cuminicable {
    public static func convert(object: AnyObject) -> Cuminicable? {
        if let x = object as? Double {
            return x
        }
        
        if let x = object as? Int {
            return Double(x)
        }
        
        return nil
    }
    
    public static func brutalize<T: Cuminicable>(object: Cuminicable, _ t: T.Type) -> Cuminicable? {
        if let x = object as? Double {
            return unsafeBitCast(x, T.self)
        }
        
        return nil
    }
}

extension Float: Cuminicable {
    public static func convert(object: AnyObject) -> Cuminicable? {
        if let x = object as? Float {
            return x
        }
        
        if let x = object as? Int {
            return Float(x)
        }
        
        return nil
    }
    
    public static func brutalize<T: Cuminicable>(object: Cuminicable, _ t: T.Type) -> Cuminicable? {
        if let x = object as? Float {
            return unsafeBitCast(x, T.self)
        }
        
        return nil
    }
}

extension Bool: Cuminicable {
    public static func convert(object: AnyObject) -> Cuminicable? {
        if let x = object as? Bool {
            return x
        }
        
        if let x = object as? Int {
            return x == 1 ? true : false
        }
        
        return nil
    }
    
    public static func brutalize<T: Cuminicable>(object: Cuminicable, _ t: T.Type) -> Cuminicable? {
        if let x = object as? Bool {
            return unsafeBitCast(x, T.self)
        }
        
        return nil
    }
}


// MARK: Tuple Handling
func arrayForTuple(tuple: Any?) -> [AnyObject]? {
    // Returns a tuple as a list of AnyObjects. If the passed arg is not a tuple, returns nil
    // If passed Void, returns an empty list.
    // If passed nil, returns nil.
    // If any returned element of the tuple is not AnyObject, returns nil
    
    // CANT handle nil values within the tuple
    
    print(tuple)
    
    if tuple == nil {
        return nil
    }
    
    let reflection = Mirror(reflecting: tuple!)
    var arr : [AnyObject] = []
    
    for value in reflection.children {
        print(value.value)
        
        if let _ = value.value as? Cuminicable {
            print("Is Cumin")
        }
        
        if let val = value.value as? AnyObject {
            arr.append(val)
        } else {
            return nil
        }
    }
    
    return arr
}
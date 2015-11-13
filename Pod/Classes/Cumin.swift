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
*/

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
    // Converts types for serialization, mostly RiffleModels
    var ret: [AnyObject] = []
    var args: [AnyObject] = []
    
    if let autoArray = convert as? [AnyObject] {
        args = autoArray
    } else {
        args = [convert]
    }
    
    for a in args {
        if let object = a as? RiffleModel {
            let converted = try MTLJSONAdapter.JSONDictionaryFromModel(object, error: ())
            ret.append(converted)
        } else if let objects = a as? [RiffleModel] {
            let converted = try MTLJSONAdapter.JSONArrayFromModels(objects, error: ())
            ret.append(converted)
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

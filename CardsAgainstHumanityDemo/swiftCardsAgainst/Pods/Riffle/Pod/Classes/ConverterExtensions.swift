//
//  ConverterExtensions.swift
//  Pods
//
//  Created by Mickey Barboi on 10/27/15.
//
//  Extensions for cumin classes that implement conversions between serialized forms and method signature forms.


import Foundation

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
            return Bool(x)
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
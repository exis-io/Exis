//
//  OsxBullshit.swift
//  Pods
//
//  Created by damouse on 4/12/16.
//
// See in swift repo: lib/irgen/runtimeFunctions
// Looks like you might be able to hook with "MSHookFunciton"
// Also check out stdlib/public/runtime/reflection, but I dont think these are accessible
// Maybe try a mirror with this?

import Foundation

// An application-exportable converter function that allows osx targets to cast appropriately
// Does this look silly or wrong to you? Good, you're a sane swift developer.
// Unfortunatly, type checking with a swift framework on OSX is not a sane endeveour. Trust
// me when I say there's an outrageous amount of subtle nonsense going on here
// TODO: put an error log detailing what to put in here if the block hasn't been assigned on OSX

public protocol ExternalType {
    var ambiguousType: Any.Type { get }
    var name: String { get }
    
    func cast<A>(arg: A) -> Convertible?
    func castType<A>(a: A.Type) -> Convertible.Type?
}

// We can use the constraint to automatically infer type for deserialization-- gives access to the class methods
// What about serialization?
public class External<T: Convertible>: ExternalType {
    public var name: String
    var typedType: T.Type
    public var ambiguousType: Any.Type
    
    
    public init(_ typed: T.Type, _ ambiguous: Any.Type) {
        typedType = typed
        ambiguousType = ambiguous
        name = "\(typed)"
    }
    
    public func cast<A>(arg: A) -> Convertible? {
        let ret = unsafeBitCast(arg, T.self)
        
        if let ret = ret as? Convertible {
            return ret
        }
        
        return nil
    }
    
    public func castType<A>(a: A.Type) -> Convertible.Type? {
        // This allows us to return the given type as a convertible... is this enough?
        if let z = T.self as? Convertible.Type {
            return z
        }
        
        return nil
    }
}

func asConvertible<A>(a: A) -> Convertible? {
    // Try to cast the given argument to convertible
    if let a = a as? Convertible {
        print("Initial cast")
        return a
    }
    
    for type in externals {
        if A.self == type.ambiguousType {
            let c = type.cast(a)
            
            return c
        }
    }
    
    return nil 
}



var externals: [ExternalType] = []

public func initTypes(types: ExternalType...) {
    externals = types
}

public func checkConvertible<A>(a: A) {
    // Check to make sure the given object is correctly recognized as a convertible
    
    if let a = a as? Convertible {
        print("Initial cast")
        return
    }
    
    for type in externals {
        if A.self == type.ambiguousType {
            let c = type.cast(a) as! Convertible
            print("Caught external type \(type.name)")
            return
        }
    }
    
    print("Failed on \(a.dynamicType)")
}




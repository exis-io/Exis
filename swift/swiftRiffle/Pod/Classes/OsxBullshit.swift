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

// This isn't needed anymore, but crashes
public var osxConvertible: ((Convertible) -> Convertible?)?
public var osxProperty: ((Property) -> Property?)?

public var collectionConvertible: (() -> ())?


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
        print("Converting types: \(arg.dynamicType) to \(T.self)")
        let ret = unsafeBitCast(arg, T.self)
        
        if let ret = ret as? Convertible {
            print("conversion succeeded")
            return ret
        }
        
        return nil
    }
    
    public func castType<A>(a: A.Type) -> Convertible.Type? {
        // print("Checking \(ambiguousType) and named types against Convertible")
        
        // This allows us to return the given type as a convertible... is this enough?
        if let z = T.self as? Convertible.Type {
            // print("Convertible type check successful!")
            return z
        }
        
        return nil
    }
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

public func checkCollection<A: CollectionType>(a: A) {
    let elementType = A.Generator.Element.self
    
    if let z = elementType as? Convertible {
        print("Convertible")
    }
    
    if let z = elementType as? Int {
        print("Int")
    }
    
    if elementType == Int.self {
        print("Direct Type Int")
    }
    
    if let z = elementType as? Convertible.Type {
        print("Recognized internal convertible type")
    }
    
    // direct type equality still works to check the internal part of the type, but the cast isnt going 
    // to work
    for type in externals {
        if elementType == type.ambiguousType {
            // This is a success case, right? Implicit detection of internal type comformance AND the type itself
            print("Caught external type \(type.name)")
            
            if let t = type.castType(elementType) {
                print("Have convertible generator type!")
            }

            
            return
        }
    }
    
    print("Done")
}





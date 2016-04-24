//
//  OsxBullshit.swift
//  Pods
//
//  Created by damouse on 4/12/16.
//
// Swift libraries are not technically supported on OSX targets-- Swift gets linked against twice
// Functionally this means that type checks in either the library or the app fail when the
// type originates on the other end.
//
// Does this look silly or wrong to you? Good, you're a sane swift developer.
// Unfortunatly, type checking with a swift framework on OSX is not a sane endeveour. Trust
// me when I say there's an outrageous amount of subtle nonsense going on here.
//
// Comments and Links:
//      See in swift repo: lib/irgen/runtimeFunctions
//      Looks like you might be able to hook with "MSHookFunciton"
//      Also check out stdlib/public/runtime/reflection, but I dont think these are accessible
//      Maybe try a mirror with this?


import Foundation

// An application-exportable converter function that allows osx targets to cast appropriately
// Does this look silly or wrong to you? Good, you're a sane swift developer.
// TODO: put an error log detailing what to put in here if the block hasn't been assigned on OSX

var externals: [ExternalType] = []

public func initTypes(types: ExternalType...) {
    externals = types
}

public protocol ExternalType {
    var ambiguousType: Any.Type { get }
    var name: String { get }
    
    func cast<A>(arg: A) -> Convertible?
    func castType<A>(a: A.Type) -> Convertible.Type?
}

// Wrapper around externally provided types. OSX applications should instantiate a set of these and pass them into initTypes
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

// Try to cast the given argument to convertible
func asConvertible<A>(a: A) -> Convertible? {
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

// Check to make sure the given object is correctly recognized as a convertible
public func checkConvertible<A>(a: A) {
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

// Encode the value of a variable to bytes and back again into the desired type
func recode<A, T>(value: A, _ t: T.Type) -> T {
    if T.self == Bool.self {
        return encodeBool(value) as! T
    }
    
    if T.self == String.self  {
        let r = encodeString(value)
        return r as! T
    }
    
    // copy the value as to not disturb the original
    let copy = value
    let data = encode(copy)
    
    let pointer = UnsafeMutablePointer<T>.alloc(sizeof(T.Type))
    data.getBytes(pointer)
    return pointer.move()
}

// Switches the types of a primitive from app type to library types
func switchTypes<A>(x: A) -> Any {
    #if os(OSX)
        switch "\(x.dynamicType)" {
        case "Int":
            return recode(x, Int.self)
        case "String":
            return recode(x, String.self)
        case "Double":
            return recode(x, Double.self)
        case "Float":
            return recode(x, Float.self)
        case "Bool":
            return recode(x, Bool.self)
        default:
            print("WARN: Unable to switch type: \(x.dynamicType)")
            return x
        }
    #else
        return x
    #endif
}

// Switch a type object to a library type
func switchTypeObject<A>(x: A) -> Any.Type {
    #if os(OSX)
        switch "\(x)" {
        case "Int":
            return Int.self
        case "String":
            return String.self
        case "Double":
            return Double.self
        case "Float":
            return Float.self
        case "Bool":
            return Bool.self
        default:
           print("WARN: Unable to switch out type object: \(x)")
            return x as! Any.Type
        }
    #else
        return x as! Any.Type
    #endif
}

// Returns the bytes from a swift as NSData
func encode<A>(var v:A) -> NSData {
    return withUnsafePointer(&v) { p in
        return NSData(bytes: p, length: strideof(A))
    }
}

// Booleans dont like the recode method as written.
func encodeBool<A>(var v:A) -> Bool {
    return withUnsafePointer(&v) { p in
        let s = unsafeBitCast(p, UnsafePointer<Bool>.self)
        return s.memory == true
    }
}

// Grab the pointer, copy out the bytes into a new string, and return it. Strings don't like the recode method as written. 
func encodeString<A>(var v:A) -> String {
    return withUnsafePointer(&v) { p in
        let s = unsafeBitCast(p, UnsafePointer<String>.self)
        let dat = s.memory.dataUsingEncoding(NSUTF8StringEncoding)!
        let ret = NSString(data: dat, encoding: NSUTF8StringEncoding)
        return ret as! String
    }
}





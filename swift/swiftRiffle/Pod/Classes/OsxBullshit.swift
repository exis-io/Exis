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

public var externals: [ExternalType] = []

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
    
    return encode(value, t)
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
func encode<A, T>(var v:A, _ t: T.Type) -> T {
    return withUnsafePointer(&v) { p in
        let d =  NSData(bytes: p, length: strideof(A))
        let pointer = UnsafeMutablePointer<T>.alloc(sizeof(T.Type))
        d.getBytes(pointer)
        return pointer.move()
    }
}

// Booleans dont like the recode method as written.
func encodeBool<A>(var v:A) -> Bool {
    return withUnsafePointer(&v) { p in
        let s = unsafeBitCast(p, UnsafePointer<Bool>.self)
        return s.memory ? true : false
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














// Playground

public func loop() {
    let s = "TARGET"
    let y = true
    rfloop(s)
}

public var crloop: ((Any) -> ())? = nil
var count = 0

public protocol ExternalCaster {
    func recodeString(a: String) -> String
    //    func recode<T>(a: Bool, t: T.Type) -> T
    
    func recode<A, T>(a: A, t: T.Type) -> T
}

public var caster: ExternalCaster? = nil

public func rfloop<A>(a: A)  {
    if let z = a as? String {
        print("Riffle has String")
        let s = caster!.recodeString(z)
        print("Riffle has \(s)")
    }
    
    print("Uh")
}


public func dmtest<A: Model>(a: A.Type) -> A? {
    let j: [String: Any] = ["name": "Anna", "age": 1000]
    print("Starting decereal")

//    let q = Tat.deserialize(j) as! Tat
//    print("Is ID assigned: \(q.xsid)")
//    
//    let c = Tat.decereal(j)
//    print("Crust decereal Tat: \(c)")
    
    let z = a.decereal(j)
    let m = z as! Model
    print("Crust decereal \(a): \(z)")
    
//    if let z = z as? A {
//        return z
//    }
    
    return z as! Model as! A
}


public protocol StubbedModel {
    static func decereal(from: [String: Any]) -> Any
}

class Tat: Model {
    var name = "Bob"
}

extension Model: StubbedModel {
    // Creates a new instance of this model object from the given json
    public static func decereal(from: [String: Any]) -> Any {
        guard let json = from as? [String: Any] else {
            print("WARN: model wasn't given a json! Instead received type: \(from.dynamicType)")
            return from
        }
        
        var ret = self.init()
        
        for n in ret.propertyNames() {
            let repr = "\(ret[n]!.dynamicType.representation())"
            
            
            // JSON is returning ints as doubles. Correct that and this isn't needed: Json.swift line 882
            if repr == "int" {
                if let value = json[n] as? Double {
                    ret[n] = Int(value)
                } else if let value = json[n] as? Float {
                    ret[n] = Int(value)
                } else if let value = json[n] as? Int {
                    ret[n] = value
                } else {
                    Riffle.warn("Model deserialization unable to cast property \(json[n]): \(json[n].dynamicType)")
                }
            }
                
                // Silvery cant understand assignments where the asigner is an AnyObject, so
            else if let value = json[n] as? Bool where "\(repr)" == "bool" {
                ret[n] = value
            }
            else if let value = json[n] as? Double where "\(repr)" == "double" || "\(repr)" == "float" {
                ret[n] = value
            }
            else if let value = json[n] as? Float where "\(repr)" == "double" || "\(repr)" == "float" {
                ret[n] = value
            }
            else if let value = json[n] as? Int where "\(repr)" == "int" {
                ret[n] = value
            }
            else if let value = json[n] as? String {
                ret[n] = value
            }
            else if let value = json[n] as? [Any] {
                ret[n] = value
            }
            else if let value = json[n] as? [String: Any] {
                ret[n] = value
            }
            else {
                Riffle.warn("Model deserialization unable to cast property \(json[n]): \(json[n].dynamicType)")
            }
        }
        
        return ret
    }
}




























































































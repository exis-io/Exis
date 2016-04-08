//
//  Extensions.swift
//  SwiftRiffle
//
//  Created by damouse on 12/29/15.
//  Copyright © 2015 Exis. All rights reserved.
//

import Foundation

#if os(Linux)
    import SwiftGlibc
    import Glibc
#else
    import Darwin.C
#endif

// All properties implement Convertible, but Models react differently 
// This allows each property to handle its construction differently
public protocol Convertible {
    func serialize() -> Any
    static func deserialize(from: Any) -> Any
    
    func unsafeSerialize() -> Any
    static func unsafeDeserialize<T>(from: Any, t: T.Type) -> T?
    
    // Returns a core representation of this type
    static func representation() -> Any
}

public protocol BaseConvertible: Convertible {}

    

extension BaseConvertible {
    public static func deserialize(from: Any) -> Any {
        return from
    }
    
    public static func unsafeDeserialize<T>(from: Any, t: T.Type) -> T? {
        return unsafeBitCast(from, t.self)
    }

    public static func representation() -> Any {
        return "\(Self.self)"
    }
    
    public func serialize() -> Any {
        return self
    }
    
    public func unsafeSerialize() -> Any {
        return self
    }
}

/// All model properties must conform to this protocol
public protocol Property: Convertible {}

extension Property {
    
    static func size() -> Int {
        return Int(ceil(Double(sizeof(self))/Double(sizeof(Int))))
    }
    
    static func type() -> Self.Type.Type {
        return self.dynamicType
    }
    
    mutating func codeInto(pointer: UnsafePointer<Int>) {
        (UnsafeMutablePointer(pointer) as UnsafeMutablePointer<Self>).memory = self
    }
    
    mutating func codeOptionalInto(pointer: UnsafePointer<Int>) {
        (UnsafeMutablePointer(pointer) as UnsafeMutablePointer<Optional<Self>>).memory = self
    }
}

protocol OptionalProperty : Property {
    static func codeNilInto(pointer: UnsafePointer<Int>)
    static func propertyType() -> Property.Type?
    func property() -> Property?
}

extension Optional : OptionalProperty {
    
    static func codeNilInto(pointer: UnsafePointer<Int>) {
        (UnsafeMutablePointer(pointer) as UnsafeMutablePointer<Optional>).memory = nil
    }
    
    static func propertyType() -> Property.Type? {
        return Wrapped.self as? Property.Type
    }
    
    func property() -> Property? {
        switch self {
        case .Some(let property):
            if let property = property as? Property {
                return property
            } else {
                return nil
            }
        default: return nil
        }
    }
}

extension Int: Property, Convertible {
    public func serialize() -> Any { return self }
    public func unsafeSerialize() -> Any { return unsafeBitCast(self, Int.self) }
    
    public static func deserialize(from: Any) -> Any {
        if let x = from as? Int {
            return x
        } else if let x = from as? String {
            return Int(x)
        } else if let x = from as? Double {
            return Int(x)
        }
        
        print("WARN: Convertible was not able to complete for type \(self) with value \(from)")
        return from
    }
    
    public static func unsafeDeserialize<T>(from: Any, t: T.Type) -> T? {
      return recode(deserialize(switchTypes(from)), t.self)
    }

    public static func representation() -> Any {
        return "int"
    }
}

extension String: Property, Convertible {
    public func serialize() -> Any { return self }
    public func unsafeSerialize() -> Any { return unsafeBitCast(self, String.self) }
    
    public static func deserialize(from: Any) -> Any {
        if let x = from as? String {
            return x
        } else if let x = from as? Int {
            return String(x)
        }
        
        print("WARN: Convertible was not able to complete for type \(self) with value \(from)")
        return from
    }
    
    public static func unsafeDeserialize<T>(from: Any, t: T.Type) -> T? {
        return recode(deserialize(switchTypes(from)), t.self)
    }

    public static func representation() -> Any {
        return "str"
    }
}

extension Double: Property, Convertible {
    public func serialize() -> Any { return self }
    public func unsafeSerialize() -> Any { return unsafeBitCast(self, Double.self) }
    
    public static func deserialize(from: Any) -> Any {
        if let x = from as? Double {
            return x
        } else if let x = from as? Int {
            return Double(x)
        }
        
        print("WARN: Convertible was not able to complete for type \(self) with value \(from)")
        return from
    }
    
    public static func unsafeDeserialize<T>(from: Any, t: T.Type) -> T? {
        return recode(deserialize(switchTypes(from)), t.self)
    }

    public static func representation() -> Any {
        return "double"
    }
}

extension Float: Property, Convertible {
    public func serialize() -> Any { return self }
    public func unsafeSerialize() -> Any { return unsafeBitCast(self, Float.self) }
    
    public static func deserialize(from: Any) -> Any {
        if let x = from as? Float {
            return x
        } else if let x = from as? Double {
            return Float(x)
        } else if let x = from as? Int {
            return Float(x)
        }
        
        print("WARN: Convertible was not able to complete for type \(self) with value \(from)")
        return from
    }
    
    public static func unsafeDeserialize<T>(from: Any, t: T.Type) -> T? {
        return recode(deserialize(switchTypes(from)), t.self)
    }

    public static func representation() -> Any {
        return "float"
    }
}

extension Bool: Property, Convertible {
    public func serialize() -> Any { return self }
    public func unsafeSerialize() -> Any { return unsafeBitCast(self, Bool.self) }
    
    public static func deserialize(from: Any) -> Any {
        if let x = from as? Bool {
            return x
        } else if let x = from as? Int {
            return x == 1 ? true : false
        }
        
        print("WARN: Convertible was not able to complete for type \(self) with value \(from)")
        return from
    }
    
    public static func unsafeDeserialize<T>(from: Any, t: T.Type) -> T? {
        return recode(deserialize(switchTypes(from)), t.self)
    }

    public static func representation() -> Any {
        return "bool"
    }
}

// Might work, but don't have time for it now
//protocol Thing: Property, Convertible {}
//extension Array: Thing {}
//
//
//extension CollectionType where Self: Thing, Generator.Element : Convertible {
//    internal static func quietRepresentation() -> Any {
//        return Generator.Element.representation()
//    }
//}

// TODO: Dictionaries
extension Array : Property, BaseConvertible {
    
    public static func deserialize(from: Any) -> Any {
        if let arr = from as? [Any] {
            var ret: [Element] = []
            
            // Reconstruct values within the array
            for element in arr {
                if let child = Generator.Element.self as? Convertible.Type {
                    ret.append(child.deserialize(element) as! Element)
                }
            }

            return ret
        }
        
        Riffle.warn("Array deserialize not given an array!")
        return from
    }
    
    public func serialize() -> Any {
        // TODO: Apply recursive serialization here
        var ret: [Any] = []
        
        for child in self {
            if let convert = child as? Convertible {
                ret.append(convert.serialize())
            }
        }
        
        return ret
    }
    
    public func unsafeSerialize() -> Any {
        // TODO: Apply recursive serialization here
        var ret: [Any] = []
        
        for child in self {
            var switched = switchTypes(child)
            if let convert = switched as? Convertible {
                ret.append(convert.serialize())
            }
        }
        
        return ret
    }
    
    public static func unsafeDeserialize<T>(from: Any, t: T.Type) -> T? {
        if let arr = from as? [Any] {
            var ret: [Element] = []
            
            // Reconstruct values within the array
            for element in arr {
                let switchedType = switchTypeObject(Generator.Element.self)
                
                if let child = switchedType as? Convertible.Type {
                    ret.append(child.unsafeDeserialize(element, t: Generator.Element.self)!)
                }
                
//                print("Have internal array type \(Generator.Element.self)")
//                
//                
//                if let child = Generator.Element.self as? Convertible.Type {
//                    ret.append(child.deserialize(element) as! Element)
//                }
            }
            
//            return ret as! T
            return unsafeBitCast(ret, t.self)
//            return recode(ret, )
        }
        
        Riffle.warn("Array unsafeDeserialize not given an array!")
        return from as! T
//        return unsafeBitCast(from, t.self)
    }

    public static func representation() -> Any {
        
        if let child = Generator.Element.self as? Convertible.Type {
            return [child.representation()]
        }
        
        // OSX hack for primitive arrays, arrays of models not possible
        var ret = "\(Generator.Element.self)"
        #if os(OSX)
            switch ret {
            case "Int":
                ret = "int"
            case "String":
                ret = "str"
            case "Double":
                ret = "double"
            case "Float":
                ret = "float"
            case "Bool":
                ret = "bool"
            default:
                break
            }
        #else
            Riffle.warn("Unable to derive representation of array! Type: \(self), returning \(ret)")
        #endif
        
        return [ret]
    }
}

// Structures

extension AnyBidirectionalCollection : Property, BaseConvertible {}
extension AnyBidirectionalIndex : Property, BaseConvertible {}
extension AnyForwardCollection : Property, BaseConvertible {}
extension AnyForwardIndex : Property, BaseConvertible {}
extension AnyRandomAccessCollection : Property, BaseConvertible {}
extension AnyRandomAccessIndex : Property, BaseConvertible {}
extension AnySequence : Property, BaseConvertible {}
extension ArraySlice : Property, BaseConvertible {}
extension COpaquePointer : Property, BaseConvertible {}
extension CVaListPointer : Property, BaseConvertible {}
extension Character : Property, BaseConvertible {}
extension ClosedInterval : Property, BaseConvertible {}
extension CollectionOfOne : Property, BaseConvertible {}
extension ContiguousArray : Property, BaseConvertible {}
extension Dictionary : Property, BaseConvertible {}
extension DictionaryGenerator : Property, BaseConvertible {}
extension DictionaryIndex : Property, BaseConvertible {}
extension DictionaryLiteral : Property, BaseConvertible {}
extension EmptyCollection : Property, BaseConvertible {}
extension EmptyGenerator : Property, BaseConvertible {}
extension EnumerateGenerator : Property, BaseConvertible {}
extension EnumerateSequence : Property, BaseConvertible {}
extension FlattenBidirectionalCollection : Property, BaseConvertible {}
extension FlattenBidirectionalCollectionIndex : Property, BaseConvertible {}
extension FlattenCollection : Property, BaseConvertible {}
extension FlattenCollectionIndex : Property, BaseConvertible {}
extension FlattenGenerator : Property, BaseConvertible {}
extension FlattenSequence : Property, BaseConvertible {}
extension GeneratorOfOne : Property, BaseConvertible {}
extension GeneratorSequence : Property, BaseConvertible {}
extension HalfOpenInterval : Property, BaseConvertible {}
extension IndexingGenerator : Property, BaseConvertible {}
extension Int16 : Property, BaseConvertible {}
extension Int32 : Property, BaseConvertible {}
extension Int64 : Property, BaseConvertible {}
extension Int8 : Property, BaseConvertible {}
extension JoinGenerator : Property, BaseConvertible {}
extension JoinSequence : Property, BaseConvertible {}
extension LazyCollection : Property, BaseConvertible {}
extension LazyFilterCollection : Property, BaseConvertible {}
extension LazyFilterGenerator : Property, BaseConvertible {}
extension LazyFilterIndex : Property, BaseConvertible {}
extension LazyFilterSequence : Property, BaseConvertible {}
extension LazyMapCollection : Property, BaseConvertible {}
extension LazyMapGenerator : Property, BaseConvertible {}
extension LazyMapSequence : Property, BaseConvertible {}
extension LazySequence : Property, BaseConvertible {}
extension ManagedBufferPointer : Property, BaseConvertible {}
extension Mirror : Property, BaseConvertible {}
extension MutableSlice : Property, BaseConvertible {}
extension ObjectIdentifier : Property, BaseConvertible {}
extension PermutationGenerator : Property, BaseConvertible {}
extension Range : Property, BaseConvertible {}
extension RangeGenerator : Property, BaseConvertible {}
extension RawByte : Property, BaseConvertible {}
extension Repeat : Property, BaseConvertible {}
extension ReverseCollection : Property, BaseConvertible {}
extension ReverseIndex : Property, BaseConvertible {}
extension ReverseRandomAccessCollection : Property, BaseConvertible {}
extension ReverseRandomAccessIndex : Property, BaseConvertible {}
extension Set : Property, BaseConvertible {}
extension SetGenerator : Property, BaseConvertible {}
extension SetIndex : Property, BaseConvertible {}
extension Slice : Property, BaseConvertible {}
extension StaticString : Property, BaseConvertible {}
extension StrideThrough : Property, BaseConvertible {}
extension StrideThroughGenerator : Property, BaseConvertible {}
extension StrideTo : Property, BaseConvertible {}
extension StrideToGenerator : Property, BaseConvertible {}
extension String.CharacterView : Property, BaseConvertible {}
extension String.CharacterView.Index : Property, BaseConvertible {}
extension String.UTF16View : Property, BaseConvertible {}
extension String.UTF16View.Index : Property, BaseConvertible {}
extension String.UTF8View : Property, BaseConvertible {}
extension String.UTF8View.Index : Property, BaseConvertible {}
extension String.UnicodeScalarView : Property, BaseConvertible {}
extension String.UnicodeScalarView.Generator : Property, BaseConvertible {}
extension String.UnicodeScalarView.Index : Property, BaseConvertible {}
extension UInt : Property, BaseConvertible {}
extension UInt16 : Property, BaseConvertible {}
extension UInt32 : Property, BaseConvertible {}
extension UInt64 : Property, BaseConvertible {}
extension UInt8 : Property, BaseConvertible {}
extension UTF16 : Property, BaseConvertible {}
extension UTF32 : Property, BaseConvertible {}
extension UTF8 : Property, BaseConvertible {}
extension UnicodeScalar : Property, BaseConvertible {}
extension Unmanaged : Property, BaseConvertible {}
extension UnsafeBufferPointer : Property, BaseConvertible {}
extension UnsafeBufferPointerGenerator : Property, BaseConvertible {}
extension UnsafeMutableBufferPointer : Property, BaseConvertible {}
extension UnsafeMutablePointer : Property, BaseConvertible {}
extension UnsafePointer : Property, BaseConvertible {}
extension Zip2Generator : Property, BaseConvertible {}
extension Zip2Sequence : Property, BaseConvertible {}

/// Enumerations

extension Bit : Property, BaseConvertible {}
extension FloatingPointClassification : Property, BaseConvertible {}
extension ImplicitlyUnwrappedOptional : Property, BaseConvertible {}
extension Mirror.AncestorRepresentation : Property, BaseConvertible {}
extension Mirror.DisplayStyle : Property, BaseConvertible {}
extension Optional : Property, BaseConvertible {}
extension PlaygroundQuickLook : Property, BaseConvertible {}
extension Process : Property, BaseConvertible {}
extension UnicodeDecodingResult : Property, BaseConvertible {}

/// Classes

extension AnyGenerator : Property, BaseConvertible {}
extension NonObjectiveCBase : Property, BaseConvertible {}
extension NSObject : Property, BaseConvertible {}
extension VaListBuilder : Property, BaseConvertible {}

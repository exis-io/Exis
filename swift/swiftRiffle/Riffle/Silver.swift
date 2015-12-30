//
//  Silver.swift
//  SwiftRiffle
//
//  Created by damouse on 12/29/15.
//  Copyright © 2015 Exis. All rights reserved.
//
//  Pure swift reflection replacing Mantle and hopefully Objective-C content

import Foundation

public protocol Silvery : Property {}

public enum SilverError : ErrorType, CustomStringConvertible {
    case TypeDoesNotConformToProperty(type: Any.Type)
    case CannotSetTypeAsType(x: Any.Type, y: Any.Type)
    public var description: String {
        switch self {
        case .TypeDoesNotConformToProperty(type: let type): return "\(type) does not conform to SwiftKVC.Property."
        case .CannotSetTypeAsType(x: let x, y: let y): return "Cannot set value of type \(x) as \(y)."
        }
    }
}


extension Silvery {
    
    /**
     Subscript for getting and setting model properties
     */
    public subscript (key: String) -> Property? {
        get {
            do {
                return try valueForKey(key)
            } catch {
                return nil
            }
        }
        set {
            do {
                try setValue(newValue, forKey: key)
            } catch {
                
            }
        }
    }
    
    public mutating func setValue(value: Property?, forKey key: String) throws {
        var offset = 0
        for child in Mirror(reflecting: self).children {
            guard let property = child.value.dynamicType as? Property.Type else { throw SilverError.TypeDoesNotConformToProperty(type: child.value.dynamicType) }
            if child.label == key {
                try self.codeValue(value, type: child.value.dynamicType, offset: offset)
                return
            } else {
                offset += property.size()
            }
        }
    }
    
    public static func allProperties() -> [String] {
        return []
    }
    
    mutating func pointerAdvancedBy(offset: Int) -> UnsafePointer<Int> {
        if let object = self as? AnyObject {
            return UnsafePointer(bitPattern: unsafeAddressOf(object).hashValue).advancedBy(offset + 2)
        } else {
            return withUnsafePointer(&self) { UnsafePointer($0).advancedBy(offset) }
        }
    }
    
    mutating func codeValue(value: Property?, type: Any.Type, offset: Int) throws {
        let pointer = pointerAdvancedBy(offset)
        if let optionalPropertyType = type as? OptionalProperty.Type, let propertyType = optionalPropertyType.propertyType() {
            if var optionalValue = value {
                try x(optionalValue, isY: propertyType)
                optionalValue.codeOptionalInto(pointer)
            } else if let nilValue = type as? OptionalProperty.Type {
                nilValue.codeNilInto(pointer)
            }
        } else if var sureValue = value {
            try x(sureValue, isY: type)
            sureValue.codeInto(pointer)
        }
    }
    
    func x(x: Any, isY y: Any.Type) throws {
        if x.dynamicType == y {
        } else if let x = x as? AnyObject, let y = y as? AnyClass where x.isKindOfClass(y) {
            
        } else {
            throw SilverError.CannotSetTypeAsType(x: x.dynamicType, y: y)
        }
    }
    
    public func valueForKey(key: String) throws -> Property? {
        var value: Property?
        for child in Mirror(reflecting: self).children {
            if child.label == key && String(child.value) != "nil" {
                if let property = child.value as? OptionalProperty {
                    value = property.property()
                } else if let property = child.value as? Property {
                    value = property
                } else {
                    throw SilverError.TypeDoesNotConformToProperty(type: child.value.dynamicType)
                }
                break
            }
        }
        return value
    }
    
}

public protocol Property {}

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

// Make sure every thing

extension AnyBidirectionalCollection : Property {}
extension AnyBidirectionalIndex : Property {}
extension AnyForwardCollection : Property {}
extension AnyForwardIndex : Property {}
extension AnyRandomAccessCollection : Property {}
extension AnyRandomAccessIndex : Property {}
extension AnySequence : Property {}
extension Array : Property {}
extension ArraySlice : Property {}
extension AutoreleasingUnsafeMutablePointer : Property {}
extension Bool : Property {}
extension COpaquePointer : Property {}
extension CVaListPointer : Property {}
extension Character : Property {}
extension ClosedInterval : Property {}
extension CollectionOfOne : Property {}
extension ContiguousArray : Property {}
extension Dictionary : Property {}
extension DictionaryGenerator : Property {}
extension DictionaryIndex : Property {}
extension DictionaryLiteral : Property {}
extension Double : Property {}
extension EmptyCollection : Property {}
extension EmptyGenerator : Property {}
extension EnumerateGenerator : Property {}
extension EnumerateSequence : Property {}
extension FlattenBidirectionalCollection : Property {}
extension FlattenBidirectionalCollectionIndex : Property {}
extension FlattenCollection : Property {}
extension FlattenCollectionIndex : Property {}
extension FlattenGenerator : Property {}
extension FlattenSequence : Property {}
extension Float : Property {}
extension GeneratorOfOne : Property {}
extension GeneratorSequence : Property {}
extension HalfOpenInterval : Property {}
extension IndexingGenerator : Property {}
extension Int : Property {}
extension Int16 : Property {}
extension Int32 : Property {}
extension Int64 : Property {}
extension Int8 : Property {}
extension JoinGenerator : Property {}
extension JoinSequence : Property {}
extension LazyCollection : Property {}
extension LazyFilterCollection : Property {}
extension LazyFilterGenerator : Property {}
extension LazyFilterIndex : Property {}
extension LazyFilterSequence : Property {}
extension LazyMapCollection : Property {}
extension LazyMapGenerator : Property {}
extension LazyMapSequence : Property {}
extension LazySequence : Property {}
extension ManagedBufferPointer : Property {}
extension Mirror : Property {}
extension MutableSlice : Property {}
extension ObjectIdentifier : Property {}
extension PermutationGenerator : Property {}
extension Range : Property {}
extension RangeGenerator : Property {}
extension RawByte : Property {}
extension Repeat : Property {}
extension ReverseCollection : Property {}
extension ReverseIndex : Property {}
extension ReverseRandomAccessCollection : Property {}
extension ReverseRandomAccessIndex : Property {}
extension Set : Property {}
extension SetGenerator : Property {}
extension SetIndex : Property {}
extension Slice : Property {}
extension StaticString : Property {}
extension StrideThrough : Property {}
extension StrideThroughGenerator : Property {}
extension StrideTo : Property {}
extension StrideToGenerator : Property {}
extension String : Property {}
extension String.CharacterView : Property {}
extension String.CharacterView.Index : Property {}
extension String.UTF16View : Property {}
extension String.UTF16View.Index : Property {}
extension String.UTF8View : Property {}
extension String.UTF8View.Index : Property {}
extension String.UnicodeScalarView : Property {}
extension String.UnicodeScalarView.Generator : Property {}
extension String.UnicodeScalarView.Index : Property {}
extension UInt : Property {}
extension UInt16 : Property {}
extension UInt32 : Property {}
extension UInt64 : Property {}
extension UInt8 : Property {}
extension UTF16 : Property {}
extension UTF32 : Property {}
extension UTF8 : Property {}
extension UnicodeScalar : Property {}
extension Unmanaged : Property {}
extension UnsafeBufferPointer : Property {}
extension UnsafeBufferPointerGenerator : Property {}
extension UnsafeMutableBufferPointer : Property {}
extension UnsafeMutablePointer : Property {}
extension UnsafePointer : Property {}
extension Zip2Generator : Property {}
extension Zip2Sequence : Property {}

/// Enumerations

extension Bit : Property {}
extension FloatingPointClassification : Property {}
extension ImplicitlyUnwrappedOptional : Property {}
extension Mirror.AncestorRepresentation : Property {}
extension Mirror.DisplayStyle : Property {}
// extension Optional : Property {}
extension PlaygroundQuickLook : Property {}
extension Process : Property {}
extension UnicodeDecodingResult : Property {}

/// Classes

extension AnyGenerator : Property {}
extension NonObjectiveCBase : Property {}
extension NSObject : Property {}
extension VaListBuilder : Property {}


// FOR EMERGENCIES ONLY: 2.2 Objc method
/*
var count = UInt32()
let classToInspect = User.self
let properties : UnsafeMutablePointer <objc_property_t> = class_copyPropertyList(classToInspect, &count)
var propertyNames = [String]()
let intCount = Int(count)

for var i = 0; i < intCount; i++ {
let property : objc_property_t = properties[i]

guard let propertyName = NSString(UTF8String: property_getName(property)) as? String else {
debugPrint("Couldn't unwrap property name for \(property)")
break
}

propertyNames.append(propertyName)
}

free(properties)
print(propertyNames)
*/

/*
Contents of SwiftKVC Playground

import Foundation
import SwiftKVC


class Dummy: NSObject, Model {

}

// Create a class or struct that conforms to Model
class User : Dummy {

var name: String?
var age: Int?
var friends: [User]?

init(name: String, age: Int, friends: [User] = []) {
self.name = name
self.age = age
self.friends = friends
}
}

var user = User(name: "Brad", age: 25)

//user.allProperties()
var list: [String] = []

//list = User.allProperties()
//print(list)


let m = Mirror(reflecting: user)

print(m)
print(m.displayStyle)
print(m.children.dynamicType)
print(m.children.count)


for child in m.children {
//    print(child.dynamicType)
//    list.append("\(child.value)")
list.append(child.label!)
}

print(list)


// Use the subscript to set values for keys
user["name"] = "Larry"
print(user.name)

// You can also use the subscript to access values
if let age = user["age"] as? Int {
print(age)
}

protocol PropertyNames {
func propertyNames() -> [String]
}

extension PropertyNames {
func propertyNames() -> [String] {
return Mirror(reflecting: self).children.filter { $0.label != nil }.map { $0.label! }
}
}

class Supes: PropertyNames {}

class Person : Supes {
var name = "Sansa Stark"
var awesome = true
}

Person().propertyNames() // ["name", "awesome"]

*/
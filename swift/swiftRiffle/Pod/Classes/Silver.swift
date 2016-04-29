//
//  Silver.swift
//  SwiftRiffle
//
//  Created by damouse on 12/29/15.
//  Copyright © 2015 Exis. All rights reserved.
//
//  Pure swift reflection replacing Mantle and Objective-C implementation

import Foundation

// All model objects implement Silvery
public protocol Silvery {
    func propertyNames() -> [String]
}

public enum SilverError : ErrorType, CustomStringConvertible {
    case TypeDoesNotConformToProperty(type: Any.Type)
    case CannotSetTypeAsType(x: Any.Type, y: Any.Type)
    public var description: String {
        switch self {
        case .TypeDoesNotConformToProperty(type: let type): return "\(type) does not conform to Silvery.Property."
        case .CannotSetTypeAsType(x: let x, y: let y): return "Cannot set value of type \(x) as \(y)."
        }
    }
}


extension Silvery {
    
    public subscript (key: String) -> Property? {
        get {
            do {
                return try valueForKey(key)
            } catch let e as SilverError {
                Riffle.warn("Unable to get \(key) on \(self.dynamicType): \(e)")
                return nil
            } catch {
                Riffle.warn("An unrecoverable error occured setting value to model")
                return nil
            }
        }
        set {
            do {
                try setValue(newValue, forKey: key)
            } catch let e as SilverError {
                Riffle.warn("Unable to set \(key) on \(self): \(e)")
            } catch {
                Riffle.warn("An unrecoverable error occured setting value to model")
            }
        }
    }
    
    // This does not take the "ignored" list into account wrt offsets, it just throws the conforming error and then nothing
    public mutating func setValue(value: Property?, forKey key: String) throws {
        print("Setting \(key) to \(value)")
        var offset = 0
        for child in Mirror(reflecting: self).children {
            
            // OSX bug
            var switched = child.value
            
            #if os(OSX)
                switched = switchTypes(child.value)
            #endif
            
            guard let property = switched.dynamicType as? Property.Type else { throw SilverError.TypeDoesNotConformToProperty(type: switched.dynamicType) }
            
            if child.label == key {
                try self.codeValue(value, type: switched.dynamicType, offset: offset)
                return
            } else {
                // print("Self.size: \(property.size()) manual: \(switched) \(getSize(switched.dynamicType))")
                print("Offset \(offset) incremented by \(property.size())")
                offset += property.size()
            }
        }
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
            if let unwrap = value {
                var optionalValue = unwrap
                try x(optionalValue, isY: propertyType)
                optionalValue.codeOptionalInto(pointer)
            } else if let nilValue = type as? OptionalProperty.Type {
                nilValue.codeNilInto(pointer)
            }
        } else if let optionalValue = value {
            var sureValue = optionalValue
            try x(sureValue, isY: type)
            print("Pointer: \(pointer)")
            sureValue.codeInto(pointer)
        }
    }
    
    func x(x: Any, isY y: Any.Type) throws {
        if x.dynamicType == y {
            // } else if let x = x as? AnyObject, let y = y as? AnyClass where x.isKindOfClass(y) {
        } else {
            throw SilverError.CannotSetTypeAsType(x: x.dynamicType, y: y)
        }
    }
    
    public func valueForKey(key: String) throws -> Property? {
        var value: Property?
        for child in Mirror(reflecting: self).children {
            if child.label == key {
                
                // OSX bug
                var switched = child.value
                
                #if os(OSX)
                    switched = switchTypes(child.value)
                #endif
                
                if let property = switched as? OptionalProperty {
                    value = property.property()
                } else if let property = switched as? Property {
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

// Trying a utility method 
func getSize<A>(a: A) -> Int  {
    // print("Vanilla type: \(A.self)")
    return sizeof(A)
}

public func testSizing<A: Property, B>(a: A, _ b: B) {
    print("Types: \(A.self), \(b.dynamicType)")
    // print("Property: \(A.simpleSize()), vanilla: \(sizeof(b.dynamicType))")
    
    // Constant checks for values: all arrays are 1
    print("size of Array<Bool>: \t\t\(Array<Bool>.size())")
    print("size of Array<Double>: \t\t\(Array<Double>.size())")
    print("size of Array<String>: \t\t\(Array<String>.size())")
    print("size of Array<Float>: \t\t\(Array<Float>.size())")
    print("size of Array<Int>: \t\t\(Array<Int>.size())")
    print("size of Array<Model>: \t\t\(Array<Model>.size())")
    
    print("size of Optional<String>: \t\t\(Optional<String>.size())") // 4
    print("size of Optional<Bool>: \t\t\(Optional<Bool>.size())") //1
    print("size of Optional<Double>: \t\t\(Optional<Double>.size())") //2
    print("size of Optional<Float>: \t\t\(Optional<Float>.size())") //1
    print("size of Optional<Int>: \t\t\(Optional<Int>.size())") // 2
    print("size of Optional<Model>: \t\t\(Optional<Model>.size())") // 1
}












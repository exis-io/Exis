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
            if child.label == key {//                print("HI")
                try self.codeValue(value, type: child.value.dynamicType, offset: offset)
                return
            } else {
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
            if child.label == key && String(child.value) != "nil" {
                
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
    
    public func propertyNames() -> [String] {
        return Mirror(reflecting: self).children.filter { $0.label != nil }.map { $0.label! }
    }
}

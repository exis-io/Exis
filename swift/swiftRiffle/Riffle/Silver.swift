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
    
    public func propertyNames() -> [String] {
        let m = Mirror(reflecting: self)
        
        var ret: [String: Any.Type] = [:]
        
        var s = ""
        for c in m.children {
            s = "\(s), \(c.label!)-\(c.value.dynamicType)"
            
            // Generate a list of the types once for the core and once for us
            ret[c.label!] = c.value.dynamicType
        }
        
        print(ret)
        
        return Mirror(reflecting: self).children.filter { $0.label != nil }.map { $0.label! }
    }
}



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
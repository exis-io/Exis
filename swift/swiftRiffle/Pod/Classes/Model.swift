//
//  Model.swift
//  RiffleTest
//
//  Created by damouse on 12/28/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation

public class Model: Silvery, Property, CustomStringConvertible {
    
    required public init() {}
    
    public var description:String {
        return "\(self.dynamicType){\(self.propertyNames().map { "\($0): \(self[$0])"}.joinWithSeparator(", "))}"
    }
}

extension Model: Convertible {
    public static func isModel() -> Bool {
        return true
    }
    
    // Creates a new instance of this model object from the given json
    public static func deserialize(from: Any) -> Any {
        guard let json = from as? [String: AnyObject] else {
            print("WARN: model wasn't given a json! Instead received type: \(from.dynamicType)")
            return from
        }
        
        var ret = self.init()
        
        _ = ret.propertyNames().map {
            print("Json: \(json[$0]): \(json[$0].dynamicType)")
            print("Repr: \(ret[$0]!.dynamicType.representation())")
            let repr = "\(ret[$0]!.dynamicType.representation())"
            
            // Silvery cant understand assignments where the asigner is an AnyObject
            if let value = json[$0] as? Bool where "\(repr)" == "bool" {
                ret[$0] = value
            }
            else if let value = json[$0] as? Double where "\(repr)" == "double" || "\(repr)" == "float" {
                ret[$0] = value
            }
            else if let value = json[$0] as? Float where "\(repr)" == "double" || "\(repr)" == "float" {
                ret[$0] = value
            }
            else if let value = json[$0] as? Int where "\(repr)" == "int" {
                ret[$0] = value
            }
            else if let value = json[$0] as? String {
                ret[$0] = value
            }
            else if let value = json[$0] as? [Any] {
                ret[$0] = value
            }
            else if let value = json[$0] as? [String: Any] {
                ret[$0] = value
            }
            else {
                Riffle.warn("Model deserialization unable to cast property \(json[$0]): \(json[$0].dynamicType)")
            }
        }
        
        // Set the properties from the json
        // TODO: recursively check for nested model objects
//        for property in ret.propertyNames() {
//            ret[property] = ret[property].property()!
//            try! ret.setValue(json[property], forKey: property)
//            ret[property] = json[property]!
//        }
        
        return ret
    }
    
    public func serialize() -> Any {
        var ret: [String: Any] = [:]
        
        for property in self.propertyNames() {
            ret[property] = self[property]!
        }
        
        return ret
    }
    
    public static func representation() -> Any {
        let me = self.init()
        var fields: [String: Any] = [:]
        
        for property in me.propertyNames() {
            fields[property] = me[property]!.dynamicType.representation()
        }
        
        // return "{\(me.propertyNames().map { "\($0): \(me[$0]!.dynamicType.representation())"}.joinWithSeparator(", "))}"
        return fields
    }
}

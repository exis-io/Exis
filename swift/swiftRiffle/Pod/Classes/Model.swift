//
//  Model.swift
//  RiffleTest
//
//  Created by damouse on 12/28/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation
import Mantle

public class Model: Silvery, Property, CustomStringConvertible {
    // This changes the offsets of pointers in Silvery and as such is very dangerous. If removed
    // subtract one from the literall offsets in pointerByOffset in Silver
    public var xsid = CBID()
    
    required public init() {}
    
    public var description:String {
        return "\(self.dynamicType){\(self.propertyNames().map { "\($0): \(self[$0])"}.joinWithSeparator(", "))}"
    }
    
    // Pass a set of strings to ignore when serializing this model
    public func ignoreProperties() -> [String] {
        return []
    }
    
    public func propertyNames() -> [String] {
        let ignored = ignoreProperties()
         return Mirror(reflecting: self).children.filter { $0.label != nil && !ignored.contains($0.label!) }.map { $0.label! }
        
//        var ret = ["xsid"]
//        ret.appendContentsOf(Mirror(reflecting: self).children.filter { $0.label != nil && !ignored.contains($0.label!) }.map { $0.label! })
//        return ret
    }
}

extension Model: Convertible {
    public static func isModel() -> Bool {
        return true
    }
    
    public func unsafeSerialize() -> Any {
        return serialize()
    }
    
    // Creates a new instance of this model object from the given json
    public static func deserialize(from: Any) -> Any {
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
                }
                else if let value = json[n] as? Float {
                    ret[n] = Int(value)
                }
                else {
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
    
    public static func unsafeDeserialize<T>(from: Any, t: T.Type) -> T? {
        let ret = deserialize(from)
        return ret as! T
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

// Core-based persistence
extension Model {
    private static var managerAddress: UInt64?
    
    // Returns a failing deferred if no initialized
    class func checkInitialized() -> Deferred? {
        guard let a = managerAddress else {
            let d = Deferred()
            d.errback(["Cannot access model object persistence without a connection! Instantiate an AppDomain first!"])
            return d
        }
        
        return nil
    }
    
    public class func count() -> OneDeferred<Int> {
        guard let address = managerAddress else {
            let d = OneDeferred<Int>()
            d.errback(["Cannot access model object persistence without a connection! Instantiate an AppDomain first!"])
            return d
        }
        
        let r = OneDeferred<Int>()
        sendCore("Count", deferred: r, address: address, args: ["\(self)"])
        return r
    }
}
//
//extension Model: Equatable {}
//
//public func ==(lhs: Model, rhs: Model) -> Bool {
//    return lhs._xsid == rhs._xsid
//}











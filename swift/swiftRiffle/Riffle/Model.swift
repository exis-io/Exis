//
//  Model.swift
//  RiffleTest
//
//  Created by damouse on 12/28/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation

public class Model: Cuminicable, Silvery, Property {
    
    required public init() {}
    
    public static func convert(object: AnyObject) -> Cuminicable? {
        return nil
    }

    public static func brutalize<T: Cuminicable>(object: Cuminicable, _ t: T.Type) -> Cuminicable? {
        return nil
    }
    
    public var description:String {
        return "\(self.dynamicType){\(self.propertyNames().map { "\($0): \(self[$0])"}.joinWithSeparator(", "))}"
    }
}

extension Model: Convertible {
    public static func isModel() -> Bool {
        return true
    }
    
    // Creates a new instance of this model object from the given json
    public static func create(from: Any) -> Any {
        // Why no AnyObject? This may change based on the JSON implementation
        
        //guard let json = from as? [String: AnyObject] else {
        guard let json = from as? [String: NSObject] else {
            print("WARN: model wasn't given a json!")
            return from
        }
        
        var ret = self.init()
        
        // Set the properties from the json 
        // NOTE: recursively check for nested model objects!
        for property in ret.propertyNames() {
            ret[property] = json[property]
        }
        
        return ret
    }
}

/*
public class RiffleModel : MTLModel, MTLJSONSerializing, Cuminicable {
    public var fabricId = Int(arc4random_uniform(UInt32.max))
    
    //Boilerplate Mantle code
    public class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        var ret = NSDictionary.mtl_identityPropertyMapWithModel(self)
        
        for k in self.ignoreProperties() {
            ret.removeValueForKey(k)
        }
        
        return ret
    }
    
    public class func ignoreProperties() -> [String] {
        // A list of properties to ignore when passing models to other agents
        return []
    }
    
    public static func convert(object: AnyObject) -> Cuminicable? {
        if let a = object as? [NSObject: AnyObject] {
            do {
                return try MTLJSONAdapter.modelOfClass(self, fromJSONDictionary: a) as? Cuminicable
            } catch {
                Riffle.warn("Unable to transform object to \(self.dynamicType)")
                return nil
            }
        }
        
        return nil
    }
    
    public override func description() -> String! {
        do {
            let json = try MTLJSONAdapter.JSONDictionaryFromModel(self, error: ())
            return "<\(self.dynamicType): \(json)>"
        } catch {
            Riffle.warn("Unable to transform object to \(self.dynamicType)")
            return nil
        }
    }
    
    public func jsonFromRiffle() -> [NSObject : AnyObject]! {
        // Dont use this yet
        
        do {
            return try MTLJSONAdapter.JSONDictionaryFromModel(self, error: ())
        } catch {
            Riffle.warn("Unable to transform object to \(self.dynamicType)")
            return nil
        }
    }
    
    public static func brutalize<T: Cuminicable>(object: Cuminicable, _ t: T.Type) -> Cuminicable? {
        return nil
    }
}

extension RangeReplaceableCollectionType where Generator.Element : MTLJSONSerializing {
    func riffleSeriaize() -> [[NSObject: AnyObject]]? {
        var ret: [[NSObject: AnyObject]] = []
        
        for element in self {
            do {
                let converted = try MTLJSONAdapter.JSONDictionaryFromModel(element, error: ())
                ret.append(converted)
            } catch {
                Riffle.warn("Unable to convert [\(Generator.Element.self)] to JSON")
                return nil
            }
        }
        
        return ret
    }
}

public func ==(lhs: RiffleModel, rhs: RiffleModel) -> Bool {
    return lhs.fabricId == rhs.fabricId
}
*/

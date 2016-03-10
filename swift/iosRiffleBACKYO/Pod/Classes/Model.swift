//
//  Model.swift
//  RiffleTest
//
//  Created by damouse on 12/28/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation

public class Model: Silvery, Property {
    
    required public init() {}
    
    public var description:String {
        return "\(self.dynamicType){\(self.propertyNames().map { "\($0): \(self[$0])"}.joinWithSeparator(", "))}"
    }
    
    func _serialize() {
        
    }
}

extension Model: Convertible {
    public static func isModel() -> Bool {
        return true
    }
    
    // Creates a new instance of this model object from the given json
    public static func deserialize(from: Any) -> Any {
        guard let json = from as? [String: Any] else {
            print("WARN: model wasn't given a json! Instead received type: \(from.dynamicType)")
            return from
        }
        
        var ret = self.init()
        
        // Set the properties from the json 
        // TODO: recursively check for nested model objects
        for property in ret.propertyNames() {
            ret[property] = json[property]
        }
        
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

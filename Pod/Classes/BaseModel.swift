//
//  BaseModel.swift
//  Pods
//
//  Created by Mickey Barboi on 10/6/15.
//
//

import Foundation

class RiffleModel {
    required init() {
        
    }
    
    func serialize() -> [String:AnyObject] {
        return [:]
    }
    
    func deserialize(json: [String:AnyObject]) {
        
    }
}

class RiffleModel : MTLModel, MTLJSONSerializing {
    var id = -1
    var created_at: NSDate?
    var updated_at: NSDate?
    
    override func isEqual(object: AnyObject?) -> Bool {
        if object_getClassName(self) != object_getClassName(object) {
            return false
        }
        
        if let object = object as? BaseObject {
            return id == object.id
        } else {
            return false
        }
    }
    
    
    //Boilerplate Mantle code
    class func appURLSchemeJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer(forName: MTLURLValueTransformerName)!
    }
    
    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [:]
    }
    
    class func JSONTransformerForKey(key: String) -> NSValueTransformer? {
        if key == "created_at" || key == "updated_at" {
            return NetworkUtils.dateFormatter()
        }
        
        return nil
    }
}
//
//  BaseModel.swift
//  Pods
//
//  Created by Mickey Barboi on 10/6/15.
//
//

import Foundation
import Mantle


public class RiffleModel : MTLModel, MTLJSONSerializing {
    var id = -1
    
    override public func isEqual(object: AnyObject?) -> Bool {
        if object_getClassName(self) != object_getClassName(object) {
            return false
        }
        
        if let object = object as? RiffleModel {
            return id == object.id
        } else {
            return false
        }
    }
    
    
    //Boilerplate Mantle code
    class func appURLSchemeJSONTransformer() -> NSValueTransformer {
        return NSValueTransformer(forName: MTLURLValueTransformerName)!
    }
    
    public class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [:]
    }
    
    public class func JSONTransformerForKey(key: String) -> NSValueTransformer? {
        return nil
    }
    
    //MARK: Old Placeholder Methods
    required override public init() {
        super.init()
        
        // A random integer. Have to deal with colliding ids. This is an ok base case
        id = Int(arc4random_uniform(UInt32.max))
    }

    required public init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func serialize() -> [String:AnyObject] {
        return [:]
    }
    
    func deserialize(json: [String:AnyObject]) {
        
    }
}
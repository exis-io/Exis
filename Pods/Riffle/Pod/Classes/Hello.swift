//
//  Hello.swift
//  Pods
//
//  Created by Mickey Barboi on 11/4/15.
//
//

import Foundation

class MDWampHello: NSObject, MDWampMessage {
    var realm: NSString?
    var details: [NSString: NSObject] = [:]
    var roles: [NSString: NSObject] = [:]
    
    required init!(payload: [AnyObject]!) {
        self.realm = payload[0] as! NSString
        self.details = payload[1] as! [NSString : NSObject]
    }
    
    func marshall() -> [AnyObject]! {
        return []
    }
}
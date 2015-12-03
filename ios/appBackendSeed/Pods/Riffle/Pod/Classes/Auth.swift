//
//  Auth.swift
//  Pods
//
//  Created by Mickey Barboi on 11/6/15.
//
//

import Foundation
import AFNetworking

func register(domain: String, requesting: String, success: () -> (), fail: () -> ()) {
    
    let args = [
        "domain": domain,
        "requestingdomain": requesting
    ]
    
    manager().POST("https://node.exis.io:8880/register", parameters: args, success: { (op: AFHTTPRequestOperation, ret: AnyObject) -> Void in
        rifflog.debug("Success")
        success()
    }) { (op: AFHTTPRequestOperation, err: NSError) -> Void in
        rifflog.debug("Failed: \(err)")
        fail()
    }
}

func login(domain: String, requesting: String, success: (token: String) -> (), fail: () -> ()) {
    
    let args = [
        "domain": domain,
        "requestingdomain": requesting
    ]
    
    manager().POST("https://node.exis.io:8880/login", parameters: args, success: { (op: AFHTTPRequestOperation, ret: AnyObject) -> Void in
        rifflog.debug("Success")
        
        if let json = ret as? [String: AnyObject] {
            let token = json["login_token"] as! String
            success(token: token)
        }
        
        print("\(ret)")
    }) { (op: AFHTTPRequestOperation, err: NSError) -> Void in
            rifflog.debug("Failed: \(err)")
        fail()
    }
}

func manager() -> AFHTTPRequestOperationManager {
    var manager = AFHTTPRequestOperationManager()
    manager.requestSerializer = AFJSONRequestSerializer() as AFJSONRequestSerializer
    manager.responseSerializer = AFJSONResponseSerializer() as AFJSONResponseSerializer
    
    manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
    manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
    
    return manager
}
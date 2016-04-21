//
//  Options.swift
//  Pods
//
//  Created by damouse on 4/21/16.
//
//  Options for domain operations

import Foundation

// Pass an options struct to any regular Domain operation, include any or all options. 
// Note that not all options are supported for each domain operation. Filtering them is a TODO
public struct Options {
    var progressive: (([Any]) -> ())?
    var details: Bool = false
    
    public init(progressive: (() -> ())? = nil, details: Bool = false) {
        if let p = progressive {
            self.progressive = { a in return p() }
        }
        
        self.details = details
    }
    
    // Marshall the dictionary into a format suitible for the core
    // Returns true if the call requires a Details object in the handler
    func marshall() -> UnsafeMutablePointer<Int8> {
        var ret: [String: Any] = [:]
        
        // TODO: implement me
        if let p = progressive {
            ret["progressive"] = true
        }
        
        if details {
            ret["details"] = true
        }
        
        let json = JSON.from(ret)
        let jsonString = json.serialize(DefaultJSONSerializer())
        return jsonString.cString()
    }
}

// Returned as the result of a details call
public class Details: Model {
    public var caller: String = ""
}
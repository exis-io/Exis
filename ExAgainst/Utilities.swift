//
//  Utilities.swift
//  ExAgainst
//
//  Created by Damouse on 11/8/15.
//  Copyright © 2015 exis. All rights reserved.
//
// A general set of utilties that both client and room can use.
// Like views, doesn't communicate over the fabric

import Foundation

// Remove element by value
extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}


// Return a random element or elements
extension Array {
    mutating func randomElements(number: Int, remove: Bool = false) -> [Generator.Element] {
        var ret: [Generator.Element] = []
        
        for _ in 0...number - 1 {
            let i = Int(arc4random_uniform(UInt32(self.count)))
            ret.append(self[i])
            
            if remove {
                self.removeAtIndex(i)
            }
        }
        
        return ret
    }
}

// Load the json file with the given name and return the strings
func loadCards(name: String) -> [String] {
    let jsonPath = NSBundle.mainBundle().pathForResource(name, ofType: "json")
    let x = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: jsonPath!)!, options: NSJSONReadingOptions.AllowFragments) as! [[String: AnyObject]]
    
    return x.map { (element: [String: AnyObject]) -> String in
        return element["text"] as! String
    }
}
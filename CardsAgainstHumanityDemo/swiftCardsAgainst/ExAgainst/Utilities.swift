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

// Remove element by value. Returns true if the object was removed, else false
extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    mutating func removeObject(object : Generator.Element) -> Generator.Element? {
        var remove: Self.Index? = nil
        var ret: Generator.Element? = nil
        
        for element in self {
            if element == object {
                remove = self.indexOf(element)
                ret = element
                break
            }
        }
        
        if let r = remove {
            self.removeAtIndex(r)
            return ret
        }
        
        return ret
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

// Utility function to generate random strings
func randomStringWithLength (len : Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString : NSMutableString = NSMutableString(capacity: len)
    
    for (var i=0; i < len; i++){
        let rand = arc4random_uniform(UInt32(letters.length))
        randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
    }
    
    return String(randomString)
}


// Routinely calls a function
class DelayedCaller {
    var timer: NSTimer?
    var target: AnyObject
    
    init(target t: AnyObject) {
        target = t
    }
    
    func startTimer(time: NSTimeInterval, selector: String, info: AnyObject? = nil) {
        // Calls the given function after (time) seconds. Used to count down the seconds on the current round
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(time, target: target, selector: Selector(selector), userInfo: info, repeats: false)
    }
    
    func cancel() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
}
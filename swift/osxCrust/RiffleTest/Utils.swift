//
//  Utils.swift
//  RiffleTest
//
//  Created by damouse on 12/9/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation

// Incompatible with Swift 2.2
//extension String {
//    func cString() -> UnsafeMutablePointer<Int8> {
//        let cs = (self as NSString).UTF8String
//        return UnsafeMutablePointer(cs)
//    }
//}

extension String {
    func cString() -> UnsafeMutablePointer<Int8> {
        var ret: UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>()
        
        self.withCString { p in
            var c = 0
            while p[c] != 0 {
                c += 1
            }
            c += 1
            let a = UnsafeMutablePointer<Int8>.alloc(c)
            a.initialize(0)
            for i in 0..<c {
                a[i] = p[i]
            }
            a[c-1] = 0
            ret = a
        }
        
        return ret
    }
}

// Decode arbitrary returns from the mantle
func decode(p: GoSlice) -> (Int64, [AnyObject]) {
    // v2.1
    let d = NSData(bytes: p.data , length: NSNumber(longLong: p.len).integerValue)
    var data = try! NSJSONSerialization.JSONObjectWithData(d, options: .AllowFragments) as! [AnyObject]
    let i = data.removeAtIndex(0) as! Int
    return (Int64(i), data)
    
    // v2.2
//    let int8Ptr = unsafeBitCast(p.data, UnsafePointer<Int8>.self)
//    let dataString = String.fromCString(int8Ptr)!
//    var data = try! JSONDecode().decode(dataString) as! JSONArrayType
//    
//    var i = data[0] as! Int
//    var ret: [Any] = []
//    data.array.removeAtIndex(0)
//    
//    for x in data.array {
//        if let y = x as? JNull {
//            
//        } else {
//            if let z = x as? Any {
//                ret.append(z)
//            }
//        }
//    }
//    
//    return (Int64(i), ret)
}

// Decode an invocation from the mantle
func invocation(slice: GoSlice) -> (Int64, Int64) {
    let (i, a) = decode(slice)
    
    if let z = a as? Int {
        return (i, Int64(z))
    } else {
        return (i, 0)
    }
    
    // let d = NSData(bytes: slice.data , length: NSNumber(longLong: slice.len).integerValue)
    // let data = try! NSJSONSerialization.JSONObjectWithData(d, options: .AllowFragments) as! NSArray
    // return ((data[0] as! NSNumber).longLongValue, (data[1] as! NSNumber).longLongValue)
}

// Generate a callbackId for passing to the mantle
func cbid() -> Int {
    
    let a = arc4random_uniform(pow(Double(2), Double(32)))
    return a
    
}
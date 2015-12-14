//
//  Utils.swift
//  RiffleTest
//
//  Created by damouse on 12/9/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation

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
func decode(p: GoSlice) -> (Int64, [Any]) {
    let int8Ptr = unsafeBitCast(p.data, UnsafePointer<Int8>.self)
    let dataString = String.fromCString(int8Ptr)!
    
    var data = try! JSONParser.parse(dataString).arrayValue!
    let i = data[0].uintValue!
    var ret: [Any] = []
    
    data.removeAtIndex(0)
    
    for x in data {
        if x == JSON.NullValue {
            print("nill")
        } else {
            ret.append(x)
        }
    }
    
    return (Int64(i), ret)
}

// Return a goslice of the JSON marshaled arguments
func marshall(args: AnyObject...) -> UnsafeMutablePointer<Int8> {
    let json = JSON.from(args)
    let jsonString = json.serialize(DefaultJSONSerializer())
    return jsonString.cString()
}

// Given a goslice, return the packed arugments within
//func unmarshall(slice: GoSlice) -> [Any] {
//    let int8Ptr = unsafeBitCast(slice.data, UnsafePointer<Int8>.self)
//    let dataString = String.fromCString(int8Ptr)!
//    
//    let data = try! JSONParser.parse(dataString).arrayValue!
//    return data
//}

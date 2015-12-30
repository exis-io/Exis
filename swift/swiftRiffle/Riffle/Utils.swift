//
//  Utils.swift
//  RiffleTest
//
//  Created by damouse on 12/9/15.
//  Copyright © 2015 exis. All rights reserved.
//


import Foundation
import CoreFoundation

#if os(Linux)
    import mantle
#endif

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
func decode(p: GoSlice) -> (UInt64, [Any]) {
    let int8Ptr = unsafeBitCast(p.data, UnsafePointer<Int8>.self)
    let dataString = String.fromCString(int8Ptr)!
    
    //print("Deserializing: \(dataString)")
    var data = try! JSONParser.parse(dataString).arrayValue!
    let i = data[0].uintValue!
    var ret: [Any] = []
    
    data.removeAtIndex(0)
    
    for x in data {
        if x == JSON.NullValue {

        } else {
            ret.append(x)
        }
    }
        
    return (UInt64(i), ret)
}

// Return a goslice of the JSON marshaled arguments as a cString
func marshall(args: Any...) -> UnsafeMutablePointer<Int8> {
    let json = JSON.from(args)
    let jsonString = json[0]!.serialize(DefaultJSONSerializer())
    print("Args: \(args) Json: \(json) String: \(jsonString)")
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

// Orphaned helper methods from old iosRiffle
// extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
//     // Remove first collection element that is equal to the given `object`:
//     mutating func removeObject(object : Generator.Element) {
//         if let index = self.indexOf(object) {
//             self.removeAtIndex(index)
//         }
//     }
// }

// func env(key: String, _ normal: String) -> String {
//     if let result = NSProcessInfo.processInfo().environment[key] {
//         return result
//     } else {
//         Riffle.debug("Unable to extract environment variable \(key). Using \(normal) instead")
//         return normal
//     }
// }


public func SetFabric(url: String) {
    MantleSetFabric(url.cString())
}

public func ApplicationLog(s: String){
    Application(s.cString())
}

public func DebugLog(s: String){
    Debug(s.cString())
}

public func InfoLog(s: String){
    Info(s.cString())
}

public func WarnLog(s: String){
    Warn(s.cString())
}

public func ErrorLog(s: String){
    Error(s.cString())
}

public func LogLevelOff() { SetLogLevelOff() }
public func LogLevelApp() { SetLogLevelApp() }
public func LogLevelErr() { SetLogLevelErr() }
public func LogLevelWarn() { SetLogLevelWarn() }
public func LogLevelInfo() { SetLogLevelInfo() }
public func LogLevelDebug() { SetLogLevelDebug() }

public func FabricDev() { SetFabricDev() }
public func FabricSandbox() { SetFabricSandbox() }
public func FabricProduction() { SetFabricProduction() }
public func FabricLocal() { SetFabricLocal() }
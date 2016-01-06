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
    
    guard var data = try! JSONParser.parse(dataString) as? [Any] else {
        print("DID NOT RECEIVE ARRAY BACK!")
        return (UInt64(0), [])
    }
    
    if let args = data[1] as? [Any] {
        return (UInt64(data[0] as! Double), args)
    } else {
        return (UInt64(data[0] as! Double), [])
    }
}

// Return a goslice of the JSON marshaled arguments as a cString
func marshall(args: [Any]) -> UnsafeMutablePointer<Int8> {
    let json = JSON.from(args)
    let jsonString = json.serialize(DefaultJSONSerializer())
    //print("Args: \(args) Json: \(json) String: \(jsonString)")
    return jsonString.cString()
}

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

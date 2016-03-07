//
//  Utils.swift
//  RiffleTest
//
//  Created by damouse on 12/9/15.
//  Copyright © 2015 exis. All rights reserved.
//


import Foundation
import CoreFoundation
import Mantle

// Biggest random number that can be choosen
let randomMax = UInt32(pow(Double(2), Double(32)) - 1)

func CBID() -> Double {
    // Create a random callback id
    let r = arc4random_uniform(randomMax);
    return Double(r)
}

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
func decode(json: String) -> (Double, [Any]) {
    guard let data = try! JSONParser.parse(json) as? [Any] else {
        print("DID NOT RECEIVE ARRAY BACK!")
        return (Double(0), [])
    }
    
    if let args = data[1] as? [Any] {
        return (Double(data[0] as! Double), args)
    } else {
        return (Double(data[0] as! Double), [])
    }
}

// Return a goslice of the JSON marshaled arguments as a cString
func marshall(args: [Any]) -> String {
    let json = JSON.from(args)
    let jsonString = json.serialize(DefaultJSONSerializer())
    //print("Args: \(args) Json: \(json) String: \(jsonString)")
    return jsonString
}

// Do we still need this here?
func serializeArguments(args: [Any]) -> [Any] {
    var ret: [Any] = []
    
    for a in args {
        if let arg = a as? Property {
            ret.append(arg.serialize())
        }
    }
    
    return ret
}

public func SetFabric(url: String) {
    MantleSetFabric(url)
}

public func Application(s: String){
    MantleApplication(s)
}

public func Debug(s: String){
    MantleDebug(s)
}

public func Info(s: String){
    MantleInfo(s)
}

public func Warn(s: String){
    MantleWarn(s)
}

public func Error(s: String){
    MantleError(s)
}

public func LogLevelOff() { MantleSetLogLevelOff() }
public func LogLevelApp() { MantleSetLogLevelApp() }
public func LogLevelErr() { MantleSetLogLevelErr() }
public func LogLevelWarn() { MantleSetLogLevelWarn() }
public func LogLevelInfo() { MantleSetLogLevelInfo() }
public func LogLevelDebug() { MantleSetLogLevelDebug() }

public func FabricDev() { MantleSetFabricDev() }
public func FabricSandbox() { MantleSetFabricSandbox() }
public func FabricProduction() { MantleSetFabricProduction() }
public func FabricLocal() { MantleSetFabricLocal() }

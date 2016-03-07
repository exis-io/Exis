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

// Hahahahah. No.
// Pass bytes and avoid this nonsense.
extension Double {
    func go() -> String {
        return String(UInt64(self))
    }
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

public class Riffle {
    public class func setFabric(url: String) {
        MantleSetFabric(url)
    }

    public class func application(s: String){
        MantleApplication(s)
    }

    public class func debug(s: String){
        MantleDebug(s)
    }

    public class func info(s: String){
        MantleInfo(s)
    }

    public class func warn(s: String){
        MantleWarn(s)
    }

    public class func error(s: String){
        MantleError(s)
    }

    public class func setLogLevelApp() { MantleSetLogLevelApp() }
    public class func setLogLevelOff() { MantleSetLogLevelOff() }
    public class func setLogLevelErr() { MantleSetLogLevelErr() }
    public class func setLogLevelWarn() { MantleSetLogLevelWarn() }
    public class func setLogLevelInfo() { MantleSetLogLevelInfo() }
    public class func setLogLevelDebug() { MantleSetLogLevelDebug() }
    
    public class func setFabricDev() { MantleSetFabricDev() }
    public class func setFabricSandbox() { MantleSetFabricSandbox() }
    public class func setFabricProduction() { MantleSetFabricProduction() }
    public class func setFabricLocal() { MantleSetFabricLocal() }
    
    public class func setCuminStrict() { MantleSetCuminStrict() }
    public class func setCuminLoose() { MantleSetCuminLoose() }
    public class func setCuminOff() { MantleSetCuminOff() }
}


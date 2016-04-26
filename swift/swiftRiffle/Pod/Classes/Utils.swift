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

let SUSPENDED_TOKEN = "_lastConnectionToken"
let SUSPENDED_DOMAIN = "_lastConnectionDomain"
let ID_UPPER_BOUND = UInt64(pow(Double(2), Double(53)))

// Generate random uint64 values
func CBID() -> UInt64 {
    var rnd : UInt64 = 0
    arc4random_buf(&rnd, sizeofValue(rnd))
    return rnd % ID_UPPER_BOUND
}

// All public static configuration and library access
public class Riffle {
    #if os(Linux)
    #else
    static let store = NSUserDefaults.standardUserDefaults()
    #endif
    
    class func save(key: String, value: String) {
        #if os(Linux)
            Riffle.warn("Persistence is not implemented on linux!")
        #else
            store.setObject(value, forKey: key)
        #endif
    }
    
    class func load(key: String) -> String? {
        #if os(Linux)
            Riffle.warn("Persistence is not implemented on linux!")
            return nil
        #else
            guard let data = store.objectForKey(key) as? String else { return nil }
            return data
        #endif
    }
    
    // Clear past saved authentication data
    public class func clearAuthenticationStore() {
        #if os(Linux)
            Riffle.warn("Persistence is not implemented on linux!")
        #else
            store.removeObjectForKey(SUSPENDED_TOKEN)
            store.removeObjectForKey(SUSPENDED_DOMAIN)
        #endif
    }
    
    // Log the given message with the riffle core
    public class func application(s: String){ sendCore("MantleApplication", args: [s]) }
    public class func debug(s: String){ sendCore("MantleDebug", args: [s]) }
    public class func info(s: String){ sendCore("MantleInfo", args: [s]) }
    public class func warn(s: String){ sendCore("MantleWarn", args: [s]) }
    public class func error(s: String){ sendCore("MantleError", args: [s]) }
    
    // Set the current log level, filtering out logged messages *below* the set priority. Defaults to Error.
    // From highest to lowest priority:
    //      App:    developer messages
    //      Error:  critical errors
    //      Warn:   non-critical errors
    //      Info:   information about domain operations, connection state, and performance
    //      Debug:  full logging of all riffle protocol messages
    public class func setLogLevelApp() { sendCore("SetLogLevelApp")  }
    public class func setLogLevelOff() { sendCore("SetLogLevelOff")  }
    public class func setLogLevelErr() { sendCore("SetLogLevelErr")  }
    public class func setLogLevelWarn() { sendCore("SetLogLevelWarn")  }
    public class func setLogLevelInfo() { sendCore("SetLogLevelInfo")  }
    public class func setLogLevelDebug() { sendCore("SetLogLevelDebug")  }
    
    // Change the URL of the fabric you'd like to connect to. Defaults to Production (node.exis.io)
    public class func setFabric(url: String) { sendCore("Fabric", args: [url]) }
    public class func setFabricDev() { sendCore("SetFabricDev") }
    public class func setFabricSandbox() { sendCore("SetFabricSandbox") }
    public class func setFabricProduction() { sendCore("SetFabricProduction") }
    public class func setFabricLocal() { sendCore("SetFabricLocal") }
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

// Repack arguments by converting to json and back
func jsonRepack<A>(a: A) -> A? {
    guard let a = a as? AnyObject else { return nil }
    
    let data = try! NSJSONSerialization.dataWithJSONObject(a, options: .PrettyPrinted)
    let repacked = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
    return repacked as? A
}

// Decode arbitrary returns from the mantle
func decode(p: UnsafePointer<Int8>) -> (UInt64, [Any]) {
    let dataString = String.fromCString(p)!
    
    guard let data = try! JSONParser.parse(dataString) as? [Any] else {
        print("DID NOT RECEIVE ARRAY BACK!")
        return (UInt64(0), [])
    }
    
    if let args = data[1] as? [Any] {
        return (UInt64(data[0] as! Double), args)
    } else {
        return (UInt64(data[0] as! Double), [])
    }
}

// Marshalls some set of arguments into Json, then a c string for core consumption
func marshall(args: [Any]) -> UnsafeMutablePointer<Int8> {
    let json = JSON.from(args)
    let jsonString = json.serialize(DefaultJSONSerializer())
    return jsonString.cString()
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

func serializeArguments(args: [Property]) -> [Any] {
    #if os(OSX)
        let c =  args.map { $0.unsafeSerialize() }
        return c
    #else
        return args.map { $0.serialize() }
    #endif
}


// Serialize the results of a handler. This is largely specific to OSX. Technically part of the generic shotgun
func serializeResults(args: ()) -> [Any] {
    return []
}

func serializeResults<A: PR>(args: (A)) -> [Any] {
    return [args.serialize()]
}

func serializeResults<A: PR, B: PR>(args: (A, B)) -> [Any] {
    return [args.0.serialize(), args.1.serialize()]
}

func serializeResults<A: PR, B: PR, C: PR>(args: (A, B, C)) -> [Any] {
    return [args.0.serialize(), args.1.serialize(), args.2.serialize()]
}

func serializeResults<A: PR, B: PR, C: PR, D: PR>(args: (A, B, C, D)) -> [Any] {
    return [args.0.serialize(), args.1.serialize(), args.2.serialize(), args.3.serialize()]
}

func serializeResults<A: PR, B: PR, C: PR, D: PR, E: PR>(args: (A, B, C, D, E)) -> [Any] {
    return [args.0.serialize(), args.1.serialize(), args.2.serialize(), args.3.serialize(), args.4.serialize()]
}

func serializeResults(results: Property...) -> Any {
    #if os(OSX)
        return results.map { $0.unsafeSerialize() }
    #else
        return results
    #endif
}





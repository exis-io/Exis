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
    //print("Args: \(args) Json: \(json) String: \(jsonString)")
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
        return args.map { $0.unsafeSerialize() }
    #else
        return args.map { $0.serialize() }
    #endif
    
}

func serializeResults() -> Any {
    return []
}

func serializeResults(results: Property...) -> Any {
    // Swift libraries are not technically supported on OSX targets-- Swift gets linked against twice
    // Functionally this means that type checks in either the library or the app fail when the 
    // type originates on the other end
    // This method switches app types back to library types by checking type strings. Only runs on OSX
    
    #if os(OSX)
        return results.map { $0.unsafeSerialize() }
    #else
        return results
    #endif
}

func switchTypes<A>(x: A) -> Any {
    // Converts app types to riffle types because of the osx bug (see above)
    
    #if os(OSX)
        switch "\(A.self)" {
        case "Int":
            return recode(x, Int.self)
        case "String":
            return recode(x, String.self)
        case "Double":
            return recode(x, Double.self)
        case "Float":
            return recode(x, Float.self)
        case "Bool":
            return recode(x, Bool.self)
        default:
            Riffle.warn("Unable to switch out app type: \(x.dynamicType)")
            return x
        }
    #else
        return x
    #endif
}

func switchTypeObject(x: Any) -> Any.Type {
    // Same as the function above, but operates on types
    // Converts app types to riffle types because of the osx bug (see above)
    
    #if os(OSX)
        switch "\(x)" {
        case "Int":
            return Int.self
        case "String":
            return String.self
        case "Double":
            return Double.self
        case "Float":
            return Float.self
        case "Bool":
            return Bool.self
        default:
            Riffle.warn("Unable to switch out type object: \(x)")
            return x as! Any.Type
        }
    #else
        return x as Any.Type
    #endif
    
}

func encode<A>(var v:A) -> NSData {
    // Returns the bytes from a swift variable
    return withUnsafePointer(&v) { p in
//        print("Original: \(p)")
        return NSData(bytes: p, length: sizeof(A))
    }
}


func recode<A, T>(value: A, _ t: T.Type) -> T {
    // encode and decode a value, magically transforming its type to the appropriate version
    // This is a workaround for OSX crap, again
    
    // copy the value as to not disturb the original
    let copy = value
    let data = encode(copy)
    
    if T.self == Bool.self {
        let force = unsafeBitCast(value, Bool.self)
        return force as! T
    }
    
    if T.self == String.self  {
        let converter = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        return converter as! T
    }
    
    let pointer = UnsafeMutablePointer<T>.alloc(sizeof(T.Type))
    
    data.getBytes(pointer)
    var ret: T = pointer.move()
    
    print("Converted to \(t). Final: \(ret.dynamicType) \(ret)")
    return ret
}


// Makes configuration calls a little cleaner when accessed from the top level 
// as well as keeping them all in one place
public class Riffle {
    public class func setFabric(url: String) {
        MantleSetFabric(url.cString())
    }

    public class func application(s: String){
        MantleApplication(s.cString())
    }

    public class func debug(s: String){
        MantleDebug(s.cString())
    }

    public class func info(s: String){
        MantleInfo(s.cString())
    }

    public class func warn(s: String){
        MantleWarn(s.cString())
    }

    public class func error(s: String){
        MantleError(s.cString())
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


// Create CBIDs on this side of the boundary. Note this makes them doubles, should be using byte arrays or 
// uint64
// TODO: Use this but convert to byte slices first
//// Biggest random number that can be choosen
//let randomMax = UInt32(pow(Double(2), Double(32)) - 1)
//
//func CBID() -> Double {
//    // Create a random callback id
//    let r = arc4random_uniform(randomMax);
//    return Double(r)
//}
//
//// Hahahahah. No.
//// Pass bytes and avoid this nonsense.
//extension Double {
//    func go() -> String {
//        return String(UInt64(self))
//    }
//}


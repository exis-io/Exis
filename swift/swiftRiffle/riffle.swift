/*
Fun fun.
*/

import Foundation
import CoreFoundation
import mantle

#if os(Linux)
    import SwiftGlibc
    import Glibc
#else
    import Darwin.C
#endif

//////////////////////////////////////
// Utils.swift
//////////////////////////////////////

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
    //print("Args: \(args) Json: \(json) String: \(jsonString)")
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


//////////////////////////////////////
// Domain.swift
//////////////////////////////////////

// Sets itself as the delegate if none provided
public protocol Delegate {
    func onJoin()
    func onLeave()
}

public class Domain {
    public var mantleDomain: UnsafeMutablePointer<Void>
    public var delegate: Delegate?
    
    public var handlers: [UInt64: (Any) -> ()] = [:]
    public var invocations: [UInt64: (Any) -> ()] = [:]
    public var registrations: [UInt64: (Any) -> (Any?)] = [:]
    
    
    public init(name: String) {
        mantleDomain = NewDomain(name.cString())
        // delegate = self
    }
    
    public init(name: String, superdomain: Domain) {
        mantleDomain = Subdomain(superdomain.mantleDomain, name.cString())
        // delegate = self
    }
    
    public func subscribe(endpoint: String, fn: (Any) -> ()) {
        let cb = CBID()
        let eb = CBID()
        let hn = CBID() 

        Subscribe(self.mantleDomain, endpoint.cString(), cb, eb, hn, "[]".cString())
        handlers[hn] = fn
    }
    
    public func register(endpoint: String, fn: (Any) -> (Any?)) {
        let cb = CBID()
        let eb = CBID()
        let hn = CBID() 

        Register(self.mantleDomain, endpoint.cString(), cb, eb, hn, "[]".cString())
        registrations[hn] = fn
    }

    public func publish(endpoint: String, _ args: Any...) {
        let cb = CBID()
        let eb = CBID()

        Publish(self.mantleDomain, endpoint.cString(), cb, eb, marshall(args))
    }
    
    public func call(endpoint: String, _ args: Any..., handler: (Any) -> ()) {
        let cb = CBID()
        let eb = CBID()

        Call(self.mantleDomain, endpoint.cString(), cb, eb, marshall(args), "[]".cString())
        invocations[cb] = handler
    }
    
    public func receive() {
        while true {
            var (i, args) = decode(Receive(self.mantleDomain))
            
            if let fn = handlers[i] {
                fn(args)
            } else if let fn = invocations[i] {
                fn(args)
            } else if let fn = registrations[i] {
                // Pop off the return arg. Note that we started passing it into crusts as a nested list for some reason. Cant remember why, 
                // but retaining that functionality until I remember. It started in the python implementation
                let unwrap = args[0] as! JSON
                var args = unwrap.arrayValue!
                
                let resultId = args.removeAtIndex(0)
                var ret = fn(args)
                ret = ret == nil ? ([] as! [Any]) : ret
                
                //print("Handling return with args: \(ret)")
                Yield(mantleDomain, UInt64(resultId.doubleValue!), marshall(ret))
            } else {
                print("No handlers found for id \(i)!")
            }
        }
    }
    
    public func join() {
        let cb = CBID()
        let eb = CBID()
        
        Join(mantleDomain, cb, eb)
        
        handlers[cb] = { a in
            if let d = self.delegate {
                d.onJoin()
            }
        }

        handlers[eb] = { a in
            if let d = self.delegate {
                d.onLeave()
            }
        }
        
        handlers[eb] = { (a: Any) in
            print("Unable to join!")
        }
        
        // Kick off the receive thread
        //let thread = NSThread(target: self, selector: "receive", object: nil)
        //thread.start()
        //NSRunLoop.currentRunLoop().run()
        receive()
    }
    
    
    // MARK: Delegate methods
    public func onJoin() { }
    public func onLeave() { }
}

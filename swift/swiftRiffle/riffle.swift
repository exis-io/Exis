/*
Fun fun.
*/

import Foundation
import CoreFoundation

#if os(Linux)
import SwiftGlibc
#endif

// Sets itself as the delegate if none provided
public protocol RiffleDelegate {
    func onJoin()
    func onLeave()
}


//////////////////////////////////////
// Utils.swift
//////////////////////////////////////

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

// Decoding specific to mantle 
func decode(p: GoSlice) -> (Int64, [Any]) {    
    //print("Received: \(s)")
    // let d = NSData(bytes: s.data , length: NSNumber(longLong: s.len).integerValue)
    // let data = try! NSJSONSerialization.JSONObjectWithData(d, options: .AllowFragments) as! [AnyObject]

    let int8Ptr = unsafeBitCast(p.data, UnsafePointer<Int8>.self)
    let dataString = String.fromCString(int8Ptr)!

    var data = try! JSONDecode().decode(dataString) as! JSONArrayType
    var i = data[0] as! Int
    var ret: [Any] = []
    data.array.removeAtIndex(0)

    for x in data.array {
        if let y = x as? JNull {
            
        } else {
            if let z = x as? Any {
                ret.append(z)
            }
        }
    }

    return (Int64(i), ret)
}

//////////////////////////////////////
// Deferred.swift
//////////////////////////////////////

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

public class Deferred {
    var _callback: ((AnyObject?) -> AnyObject?)? = nil
    var _errback: ((AnyObject?) -> AnyObject?)? = nil
    
    var fired = false
    
    public init() {}
    
    public func callback(args: AnyObject? = nil) -> AnyObject? {
        if fired {
            print("Defereds can only fire once!")
            return nil
        }
        
        fired = true
        
        if let cb = _callback {
            return cb(args)
        } else {
            print("No callback registered")
            return nil
        }
    }
    
    public func errback(args: AnyObject? = nil) -> AnyObject? {
        if fired {
            print("Defereds can only fire once!")
            return nil
        }
        
        fired = true
        
        if let cb = _errback {
            return cb(args)
        } else {
            print("No callback registered")
            return nil
        }
    }
    
    
    public func addCallback(cb: (AnyObject?) -> (AnyObject?)) -> Deferred {
        _callback = cb
        return self
    }
    
    public func addErrback(cb: (AnyObject?) -> (AnyObject?)) -> Deferred {
        _errback = cb
        return self
    }
}

//////////////////////////////////////
// Domain.swift
//////////////////////////////////////

public class Domain {
    var mantleDomain: UnsafeMutablePointer<Void>
    var handlers: [Int64: (Any) -> (Any?)] = [:]
    
    public var delegate: RiffleDelegate?
    
    
    public init(name: String) {
        mantleDomain = NewDomain(name.cString())
        // delegate = self
    }
    
    public func subscribe(domain: String, fn: (Any) -> ()) {
        let (cb, _) = invocation(Subscribe(mantleDomain, domain.cString()))
    
        handlers[cb] = { (a: Any) -> (Any?) in
            fn(a)
            return nil
        }
    }
    
    public func register(domain: String, fn: (Any) -> (Any?)) {
        let (cb, _) = invocation(Register(mantleDomain, domain.cString()))
        
        handlers[cb] = { (a: Any) -> (Any?) in
            return fn(a)
        }
    }
    
    func receive() {
        while true {
            let (i, args) = decode(Recieve())

            if let handler = handlers[Int64(i)] {
                if let a = args as? Any {
                    //Cuminicate here
                    handler(a)
                } else {
                    print("Unknown args \(args)")
                }
            } else {
                print("No handler found for subscription \(i)")
                print(handlers)
            }
            
            /*
            if let results = handlers[data[0].longLongValue]!(args) {
                let json: [String: AnyObject] = [
                    "id": String(Int64(data["request"] as! Double)),
                    "ok": "",
                    "result": results
                ]

                let out = try! NSJSONSerialization.dataWithJSONObject(json, options: . PrettyPrinted)

                let slice = GoSlice(data: UnsafeMutablePointer<Void>(out.bytes), len: NSNumber(integer: out.length).longLongValue, cap: NSNumber(integer: out.length).longLongValue)
                Yield(slice)
            }
            */
        }
    }
    
    public func join() {
        let (cb, eb) = invocation(Join(mantleDomain))
        
        handlers[cb] = { (a: Any) -> (Any?) in
            if let d = self.delegate {
                d.onJoin()
            }

            return nil
        }
        
        handlers[eb] = { (a: Any) -> (Any?) in
            print("Unable to join!")
            return nil
        }
        
        // Threading here
        receive()
    }
    
    
    // MARK: Delegate methods
    public func onJoin() { }
    public func onLeave() { }
}
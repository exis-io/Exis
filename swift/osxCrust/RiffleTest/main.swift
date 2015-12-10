// Testing

import Foundation

SetLoggingLevel(3)

<<<<<<< HEAD

// Interface object for interacting with goRiffle
class Domain: NSObject {
    var mantleDomain: UnsafeMutablePointer<Void>
    var handlers: [Int64: (AnyObject) -> (AnyObject?)] = [:]

    init(name: String) {
        mantleDomain = NewDomain(name.cString())
    }
    
    func subscribe(domain: String, fn: (AnyObject) -> ()) {
        
        //#if os(OSX)
        let s = Subscribe(mantleDomain, domain.cString())
        let d = NSData(bytes: s.data , length: NSNumber(longLong: s.len).integerValue)
        let data = try! NSJSONSerialization.JSONObjectWithData(d, options: .AllowFragments)
        print(data)
        //#endif
        
//        handlers[data.longLongValue] = { (a: AnyObject) -> (AnyObject?) in
//            fn(a)
//            return nil
//        }
    }
    
//    func register(domain: String, fn: (AnyObject) -> (AnyObject)) {
//        
//        //#if os(OSX)
//        Register(remoteDomain, domain.cString())
//        //let d = NSData(bytes: s.data , length: NSNumber(longLong: s.len).integerValue)
//        //let data = try! NSJSONSerialization.JSONObjectWithData(d, options: .AllowFragments) as! NSDecimalNumber
//        //#endif
//        
//        // small trick to use homogenous handlers
//        handlers[data.longLongValue] = { (a: AnyObject) -> (AnyObject?) in
//            return [fn(a)]
//        }
//    }
//    
    func receive() {
        while true {
            let s = Recieve()
            
            let d = NSData(bytes: s.data , length: NSNumber(longLong: s.len).integerValue)
            let data = try! NSJSONSerialization.JSONObjectWithData(d, options: .AllowFragments) as! [String: AnyObject]
            
            // All these need to be dispatched to background
            
            if let results = handlers[Int64(data["id"] as! Double)]!(data["data"]!) {
                let json: [String: AnyObject] = [
                    "id": String(Int64(data["request"] as! Double)),
                    "ok": "",
                    "result": results
                ]

                let out = try! NSJSONSerialization.dataWithJSONObject(json, options: . PrettyPrinted)

                let slice = GoSlice(data: UnsafeMutablePointer<Void>(out.bytes), len: NSNumber(integer: out.length).longLongValue, cap: NSNumber(integer: out.length).longLongValue)
                Yield(slice)

            }
            
            // todo: call
        }
    }
}


let g = Domain(name: "xs.damouse")

g.subscribe("sub") { (obj: AnyObject)  in
    print("Sub received: \(obj)")
}


// Threading implementation
let thread = NSThread(target: g, selector: "receive", object: nil)
thread.start()
NSRunLoop.currentRunLoop().run()

=======
//let url = "ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws"
//let domain = "xs.damouse"

class TestingDomain: Domain {
    
    override func onJoin() {
        print("Subclass joined!")
        
        register("reg") { (args: Any) -> Any? in
            print("Received call! Args: \(args)")
            return nil
        }
        
        subscribe("sub") { (args: Any) in
            print("Received publish! \(args)")
        }
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

TestingDomain(name: "xs.damouse").join()
>>>>>>> master

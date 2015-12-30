// Local testing only.

import Foundation

class Dog: Model {
    var name = "Fido"
    var age = 43
}

// Sample usage of dynamic assignment
var d = Dog()

print(d.propertyNames())

print(d.name)
d["name"] = "Spot"
print(d.name)

var holder: (([Any]) -> ())? = nil

func newcumin<A: Property, B: Property, C: Property>(fn: (A, B, C) -> ()) {
    // Assume we're getting primitive types well-constructed
    // Detect collections and objects, build them appropriately
    
    // NOTE: Collections only need to be detected for nested objects
    
    print("C is a model: \(C.isModel())")
    
    holder = { args in
        fn(args[0] as! A, args[1] as! B, args[2] as! C)
    }
}

func add(a: Int, b: [String], c: Dog) {
    print("Adding: \(a), with list: \(b), and user: \(c.name)")
}

newcumin(add)

holder!([1, ["Hey", "There"], Dog()])



/*
SetLogLevelDebug()
SetFabricLocal()


class Sender: Domain {
    
    override func onJoin() {
        publish("xs.damouse.alpha/sub", 1, "2", true)
        
        call("xs.damouse.alpha/reg", "Johnathan", "Seed") { returnArgs in
            print("Call received result \(returnArgs)")
        }
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}


class Receiver: Domain {
    
    override func onJoin() {
        register("reg") { (args: Any) -> Any? in
            print("Received call! Args: \(args)")
            return "Receiver says hi!"
        }
        
        subscribe("sub") { (args: Any) in
            print("Received publish! \(args)")
        }
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

//Receiver(name: "xs.damouse.alpha").join()

// Start the scripts
if let result = NSProcessInfo.processInfo().environment["RECEIVER"] {
    print("Starting Receiver")
    Receiver(name: "xs.damouse.alpha").join()
} else {
    print("Starting Sender")
    Sender(name: "xs.damouse.beta").join()
}
*/
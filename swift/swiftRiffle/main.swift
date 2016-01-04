// Local testing only.

import Foundation


class Dog: Model {
    var name = "Fido"
    var age = 43
}

/*
var holder: (([Any]) -> ())? = nil

func newcumin<A: Property, B: Property, C: Property>(fn: (A, B, C) -> ()) {
    // Assume we're getting primitive types well-constructed
    // Detect collections and objects, build them appropriately
    
    // NOTE: Collections only need to be detected for nested objects
    
    // Construct cumin strings here and pass to core-- repr might be betterer
    //print("C is a model: \(C.isModel())")
    
    holder = { args in
        // Coerce types, constructing them if needed, and call the function with the results
        fn(A.create(args[0]) as! A, B.create(args[1]) as! B, C.create(args[2]) as! C)
    }
}

func add(a: Int, b: [String], c: Dog) {
    print("Adding: \(a), with list: \(b), and pup: \(c.description)")
}

newcumin(add)

holder!([1, ["Hey", "There"], ["name": "Billiam", "age": 88]])
*/



SetLogLevelDebug()
SetFabricLocal()


class Sender: Domain {
    
    override func onJoin() {
        let dog = Dog()
        dog.name = "Billiam"
        dog.age = 88
        
        publish("xs.damouse.alpha/sub", 1, ["Hey", "There"], dog)
        
        call("xs.damouse.alpha/reg", "Johnathan", "Seed") { (a: String) in
            print("Call received: ", a)
        }
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}


class Receiver: Domain {
    
    override func onJoin() {
        register("reg") { (first: String, second: String) -> String in
            print("Received call! Args: ", first, second)
            return "Receiver says hi!"
        }
        
        subscribe("sub") { (a: Int, b: [String], c: Dog) in
            //print("Received publish! \(args)")
            print("Received publish: \(a), with list: \(b), and pup: \(c.description)")
        }
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

//Receiver(name: "xs.damouse.alpha").join()

let startSender = NSProcessInfo.processInfo().environment["SENDER"] != nil

// Start the scripts
if startSender {
    print("Starting Sender")
    Sender(name: "xs.damouse.beta").join()
} else {
    print("Starting Receiver")
    Receiver(name: "xs.damouse.alpha").join()
}

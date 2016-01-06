
// Local testing only.

import Foundation

SetLogLevelDebug()
//SetLogLevelInfo()
SetFabricLocal()

class Dog: Model {
    var name = "Fido"
    var age = 43
}

class Sender: Domain {
    
    override func onJoin() {
        
        // Create an object
        let dog = Dog()
        dog.name = "Billiam"
        dog.age = 88
        
        // Publish the object and assorted other arguments
        publish("xs.damouse.alpha/sub", 1, ["Hey", "There", "Bob"], dog).then {
            print("Publish succeeded")
        }.error { reason in
            print("An error occured", reason)
        }
        
        // Call with assorted arguments, stipulating the resulting return types
        call("xs.damouse.alpha/reg", "Johnathan", "Seed").then { (a: String) in
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
            print("Received publish: \(a), with list: \(b), and pup: \(c.description)")
        }
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

// Allows this script to act as a receiver or a sender
let startSender = NSProcessInfo.processInfo().environment["SENDER"] != nil

if startSender {
    print("Starting Sender")
    Sender(name: "xs.damouse.beta").join()
} else {
    print("Starting Receiver")
    Receiver(name: "xs.damouse.alpha").join()
}

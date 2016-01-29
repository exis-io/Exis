
// Local testing only.

import Foundation

SetLogLevelDebug()
//SetLogLevelInfo()
SetFabricLocal()

class Dog: Model {
    var name = "Fido"
    var age = 43
}


class Receiver: Domain {
    
    override func onJoin() {
        print("Recever joined")
        
//        register("reg") { (first: String, second: String) -> String in
//            print("Received call! Args: ", first, second)
//            return "Receiver says hi!"
//        }
//        
//        subscribe("sub") { (a: Int, b: [String], c: Dog) in
//            print("Received publish: \(a), with list: \(b), and pup: \(c.description)")
//        }

        
        // Pub Sub Success Cases
            
        // No arguments
        subscribe("subscribeNothing") {
            print("SUCCESS --- 1-1")
        }
        
        // Primitive Types
        subscribe("subscribePrimitives") { (a: Int, b: Float, c: Double, d: String, e: Bool) in
            print("SUCCESS --- 1-2")
            //print("1 : Sub receiving single types:", a, b, c, d, e)
            
            assert(a == 1)
            assert(b == 2.2)
            assert(c == 3.3)
            assert(d == "4")
            assert(e == true)
        }
        
        // Arrys of simple types
        subscribe("subscribeArrays") { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) in
            print("SUCCESS --- 1-3 ")
            //print("Received: \(a) \(b) \(c) \(d) \(e), expecting 1 2.2 3.3 4 true")
            
            assert(a == [1, 2])
            assert(b == [2.2, 3.3])
            assert(c == [4.4, 5.5])
            assert(d == ["6", "7"])
            assert(e == [true, false])
        }
        
        
        // TODO: subscribe with model object
        
        // TODO: Dictionaries of simple types
        
        // TODO: Any
        
        
        // Reg/Call Success Cases
        // No arguments
        register("registerNothing") {
            print("SUCCESS --- 2-1")
            return
        }
        
        
        // Simple Types
        // FAIL when returning the types back to the client 
        // FAIL with no cumin enforcement present
        register("registerPrimitives") { (a: Int, b: Float, c: Double, d: String, e: Bool)  in
            print("SUCCESS --- 2-2")
            //print("Received: \(a) \(b) \(c) \(d) \(e), expecting 1 2.2 3.3 4 true")
            
            assert(a == 1)
            assert(b == 2.2)
            assert(c == 3.3)
            assert(d == "4")
            assert(e == true)
            
//            return [a, b, c, d, e]
        }
        
        // Collections of simple types
        register("registerArrays") { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) in
            print("SUCCESS --- 2-3")
            //print("Received: \(a) \(b) \(c) \(d) \(e), expecting 1 2.2 3.3 4 true")
            
            assert(a == [1, 2])
            assert(b == [2.2, 3.3])
            assert(c == [4.4, 5.5])
            assert(d == ["6", "7"])
            assert(e == [true, false])
        }
        
        
        // Riffle Model objects with returns
//            register("registerModel") { (d: Dog) -> Dog in
//                //print("Recieved:\(d), expecting: \(dog)")
//                assert(d == dog)
//                return d
//            }
//            
//            receiver.call("asdf", dog).then { (d: Dog) in
//                //print("\(t) Recieved\(d), expecting \(dog)")
//                assert(d == dog)
//            })
//            
//            
//            // Collections of Riffle Model Objects
//            let dogs = [Dog(1, "1"), Dog(1, "1"), Dog(1, "1")]
//            
//            // Test both sending and receiving types
//            // Test receiving collections in invocation
//            register("registerModelArrays") { (d: [Dog]) -> AnyObject in
//                print("\(t) : Register receiving model object:", d.count)
//                print("                          expecting: \(dogs.count)\n")
//                return d
//            }
//            
//            // WARNING: cant receive 5 elements in return
//            receiver.call("registerModelArrays", [Dog(), Dog(), Dog()]).then { (dogs: [Dog]) in
//                print("\(t) : Call receiving object collection:", dogs)
//                print("                      expecting: 1 2.0 3.0 4\n")
//            })
//            
//            
//            // Leave
//            self.leave()
        
        
        // Unsub
        
        
        // Unreg
        
        
        // Test call doesnt exist
        
        
        // Test Receiver Cumin Error
        
        
        // Test Caller Cumin Error
        
        
        
        
        
        // Example Pub/Sub Basic - This is a basic version of a pub/sub
        // subscribe("sub") { (a: Int, b: [String], c: Dog) in
        //     print("Received publish: \(a), with list: \(b), and pup: \(c.description)")
        // }.then {
        //     print("Subscription succeeded")
        // }.error { reason in
        //     print("An error occured", reason)
        // }
        // End Example Pub/Sub Basic
        
        // Example Reg/Call Basic 1 - This is a basic reg/call
        // register("basicReg") { (args: String) -> String in
        //     print("\(args)") // Expects a String, like "Hello"
        //     return "Hello World"
        // }.then {
        //     self.subscribe("pubby") {
        //         print("Receiver-Sender publish received")
        //     }
        // }
        // End Example Reg/Call Basic 1
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}
    
var receiver: Receiver!


class Sender: Domain {
    override func onJoin() {
        print("Sender joined")
        
        // Create an object
        let dog = Dog()
        dog.name = "Billiam"
        dog.age = 88

        
        // Pub Sub Success Cases
        // No args
//        print("Receiver: \(receiver)")
        receiver.publish("subscribeNothing")
        
//        // Primitive Types
        receiver.publish("subscribePrimitives", 1, 2.2, 3.3, "4", true)
//
//        // Arrys of simple types
        receiver.publish("subscribeArays", [1, 2], [2.2, 3.3], [4.4, 5.5], ["6", "7"], [true, false])
//
//        
//        // Reg/Call Success Cases
//        // No arguments
        receiver.call("registerNothing").then {
            assert(true)
        }
//
//        // Primitive Types
        receiver.call("registerPrimitives", 1, 2.2, 3.3, "4", true)
//            .then { (a: Int, b: Float, c: Double, d: String, e: Bool) in
//            assert(a == 1)
//            assert(b == 2.2)
//            assert(c == 3.3)
//            assert(d == "4")
//            assert(e == true)
//        }

        // Collections of simple types
        receiver.call("registerPrimitives", [1, 2], [2.2, 3.3], [4.4, 5.5], ["6", "7"], [true, false]).then { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) in
            assert(a == [1, 2])
            assert(b == [2.2, 3.3])
            assert(c == [4.4, 5.5])
            assert(d == ["6", "7"])
            assert(e == [true, false])
        }.error { reason in
            // TODO: the reason itself is not given, instead its the class of argument
            print("FAILURE ON CALL --- 2-2")
            print("\tREASON: \(reason)")
        }

        // Example Pub/Sub Basic - This is a basic version of a pub/sub
        //publish("xs.test.example/basicSub", "Hello")
        // End Example Pub/Sub Basic
        
        // Example Reg/Call Basic 1 - This is a basic reg/call
        // call("basicReg", "Hello").then { (a: String) in
        //     print(a) // Expects a String, like "Hello World"
        //     self.publish("pubby")
        // }
        // End Example Reg/Call Basic 1
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

// Allows this script to act as a receiver or a sender
let startSender = NSProcessInfo.processInfo().environment["SENDER"] != nil

let app = Domain(name: "xs.tester")
let sender = Sender(name: "beta", superdomain: app)
receiver = Receiver(name: "alpha", superdomain: app)

if startSender {
    print("Starting Sender")
    sender.join()
} else {
    print("Starting Receiver")
    receiver.join()
}

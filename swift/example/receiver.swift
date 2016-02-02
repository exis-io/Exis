
import Riffle

/*
Because arbiter is broken at the time of this writing, receiver.swift and client.swift 
manually implemenmt a test suite for now. 

Tests (Success):
    Publish
    Subscribe
    Register
    Call

    Primitive Types
    Arrays
    Dictionaries
    Model Objects

    Errors on Connection
*/


class Dog: Model {
    var name = "Fido"
    var age = 43
}

class Receiver: Riffle.Domain, Riffle.Delegate {

    override func onJoin() {
        // Pub Sub Success Cases

        /*
        // No arguments
        subscribe("subscribeNothing") { 
            print("Publish success")
        }

        // Primitive Types
        subscribe("subscribePrimitives") { (a: Int, b: Float, c: Double, d: String, e: Bool) in
            //print("1 : Sub receiving single types:", a, b, c, d, e)
            
            assert(a == 1)
            assert(b == 2.2)
            assert(c == 3.3)
            assert(d == "4")
            assert(e == true)
        }

        // Arrys of simple types 
        subscribe("subscribeArrays") { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) in
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
            return
        }


        // Simple Types
        register("registerPrimitives") { (a: Int, b: Float, c: Double, d: String, e: Bool) -> AnyObject in
            //print("Received: \(a) \(b) \(c) \(d) \(e), expecting 1 2.2 3.3 4 true")
            
            assert(a == 1)
            assert(b == 2.2)
            assert(c == 3.3)
            assert(d == "4")
            assert(e == true)
            
            return [a, b, c, d, e]
        }
        
        // Collections of simple types
        register("registerArrays") { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) in
            //print("Received: \(a) \(b) \(c) \(d) \(e), expecting 1 2.2 3.3 4 true")
            
            assert(a == [1, 2])
            assert(b == [2.2, 3.3])
            assert(c == [4.4, 5.5])
            assert(d == ["6", "7"])
            assert(e == [true, false])
        }


        // Riffle Model objects with returns
        register("registerModel") { (d: Dog) -> Dog in
            //print("Recieved:\(d), expecting: \(dog)")
            assert(d == dog)
            return d
        }
        
        receiver.call("asdf", dog).then { (d: Dog) in
            //print("\(t) Recieved\(d), expecting \(dog)")
            assert(d == dog)
        })


        // Collections of Riffle Model Objects
        let dogs = [Dog(1, "1"), Dog(1, "1"), Dog(1, "1")]
        
        // Test both sending and receiving types
        // Test receiving collections in invocation
        register("registerModelArrays") { (d: [Dog]) -> AnyObject in
            print("\(t) : Register receiving model object:", d.count)
            print("                          expecting: \(dogs.count)\n")
            return d
        }
        
        // WARNING: cant receive 5 elements in return
        receiver.call("registerModelArrays", [Dog(), Dog(), Dog()]).then { (dogs: [Dog]) in
            print("\(t) : Call receiving object collection:", dogs)
            print("                      expecting: 1 2.0 3.0 4\n")
        })


        // Leave
        self.leave()
        */

        // Unsub


        // Unreg


        // Test call doesnt exist


        // Test Receiver Cumin Error


        // Test Caller Cumin Error




        /*
        // Example Pub/Sub Basic - This is a basic version of a pub/sub
        subscribe("basicSub") { (a: String) in
            print("Received publish: \(a)")
        }.then {
            print("Subscription succeeded")
        }.error { reason in
            print("An error occured", reason)
        }
        // End Example Pub/Sub Basic
        */

        /*
        // Example Reg/Call Basic 1 - This is a basic reg/call
        register("basicReg") { (args: String) -> String in
            print("\(args)") // Expects a String, like "Hello"
            return "Hello World"
        }
        // End Example Reg/Call Basic 1
        */
    }
    
    override func onLeave() {
        print("Receiver left!")
    }
}


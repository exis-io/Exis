//
//  DomainTesting.swift
//  Riffle
//
//  Created by damouse on 3/6/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Riffle

class Dog: Model {
    var name = "Fido"
    var age = 43
}

// Create an object
let dog = Dog()


class Receiver: Domain {
    var joinFinished: (() -> ())!
    
    override func onJoin() {
        print("Recever joined")
        
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
        
        //        subscribe("subscribeModel") { (d: Dog) in
        //            //print("Recieved:\(d), expecting: \(dog)")
        //            print("SUCESS --- 1-4")
        //            assert(d.name == dog.name && d.age == dog.age)
        //        }
        
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
        register("registerPrimitives") { (a: Int, b: Float, c: Double, d: String, e: Bool) in
            print("SUCCESS --- 2-2")
            //print("Received: \(a) \(b) \(c) \(d) \(e), expecting 1 2.2 3.3 4 true")
            
            assert(a == 1)
            assert(b == 2.2)
            assert(c == 3.3)
            assert(d == "4")
            assert(e == true)
            
            // Be very careful with the return types here
            // Cant box them into an array, since we can't differentiate between array returns and multiple value returns
            //return [a, b, c, d, e]
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
        register("registerModel") { (d: Dog) -> Dog in
            print("Recieved:\(d), expecting: \(dog)")
            assert(d.name == dog.name && d.age == dog.age)
            return d
        }

        
        //            receiver.call("asdf", dog).then { (d: Dog) in
        //                //print("\(t) Recieved\(d), expecting \(dog)")
        //                assert(d == dog)
        //            })
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
        joinFinished()
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

class Sender: Domain {
    var receiver: Receiver!
    
    override func onJoin() {
        print("Sender joined")
        
        // Pub Sub Success Cases
        // No args
        receiver.publish("subscribeNothing")
        
        // Primitive Types
        receiver.publish("subscribePrimitives", 1, 2.2, 3.3, "4", true)
        
        // Arrys of simple types
        receiver.publish("subscribeArrays", [1, 2], [2.2, 3.3], [4.4, 5.5], ["6", "7"], [true, false])
        
        // Model not reconstructed well
        // receiver.publish("subscribeModel", dog)
        
        
        // Reg/Call Success Cases
        // No arguments
        receiver.call("registerNothing").then {
            assert(true)
        }
        
        // Primitive Types
        receiver.call("registerPrimitives", 1, 2.2, 3.3, "4", true).then { (a: Int, b: Float, c: Double, d: String, e: Bool) in
            assert(a == 1)
            assert(b == 2.2)
            assert(c == 3.3)
            assert(d == "4")
            assert(e == true)
            
            print("SUCCCES --- 2-4")
        }
        
        // Collections of simple types
        receiver.call("registerArrays", [1, 2], [2.2, 3.3], [4.4, 5.5], ["6", "7"], [true, false]).then { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) in
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
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

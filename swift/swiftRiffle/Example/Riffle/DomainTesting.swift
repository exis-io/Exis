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
    var something: Double = 1.0
}

// Create an object
let dog = Dog()
let dogs = [dog, dog, dog]


class Receiver: Domain {
    var joinFinished: (() -> ())!
    
    override func onJoin() {
        print("Recever joined")
        dog.age = 21
        dog.name = "Trump"
        dog.something = 56.4
        
        // Pub Sub Success Cases
        
        
        // No arguments
//        subscribe("subscribeNothing") {
//            print("SUCCESS --- 1-1")
//        }
//        
//        // Primitive Types
//        subscribe("subscribePrimitives") { (a: Int, b: Float, c: Double, d: String, e: Bool) in
//            print("SUCCESS --- 1-2")
//            //print("1 : Sub receiving single types:", a, b, c, d, e)
//            
//            assert(a == 1)
//            assert(b == 2.2)
//            assert(c == 3.3)
//            assert(d == "4")
//            assert(e == true)
//        }
//        
//        // Arrys of simple types
//        subscribe("subscribeArrays") { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) in
//            print("SUCCESS --- 1-3 ")
//            //print("Received: \(a) \(b) \(c) \(d) \(e), expecting 1 2.2 3.3 4 true")
//            
//            assert(a == [1, 2])
//            assert(b == [2.2, 3.3])
//            assert(c == [4.4, 5.5])
//            assert(d == ["6", "7"])
//            assert(e == [true, false])
//        }
//        
//        subscribe("subscribeModel") { (d: Dog) in
//            //print("Recieved:\(d), expecting: \(dog)")
//            print("SUCESS --- 1-4")
//            assert(d.name == dog.name && d.age == dog.age)
//        }
//        
//        // TODO: subscribe with model object
//        // TODO: Dictionaries of simple types
//        // TODO: Any
//        
//        
//        // Reg/Call Success Cases
//        // No arguments
//        register("registerNothing") {
//            print("SUCCESS --- 2-1")
//        }
//        
//        
//        // Simple Types
//        // FAIL when returning the types back to the client
//        // FAIL with no cumin enforcement present
//        // FAIL with floats
//        register("registerPrimitives") { (a: Int, c: Double, d: String, e: Bool) -> Any in
//            print("SUCCESS --- 2-2")
//            
//            assert(a == 1)
//            //assert(b == 2.2)
//            assert(c == 3.3)
//            assert(d == "4")
//            assert(e == true)
//
//            return (a, c, d, e)
//        }
//        
//        
//        // Collections of simple types
//        register("registerArrays") { (a: [Int], c: [Double], d: [String], e: [Bool]) -> Any in
//            print("SUCCESS --- 2-3")
//            
//            assert(a == [1, 2])
//            //assert(b == [2.2, 3.3])
//            assert(c == [4.4, 5.5])
//            assert(d == ["6", "7"])
//            assert(e == [true, false])
//            
//            return (a, c, d, e)
//        }
        
//        register("registerSinglePrimitive") { (a: Int) -> Any in
//            print("SUCCESS --- 2-5")
//            assert(a == 1)
//            return a
//        }
        
        // Riffle Model objects with returns
        register("registerModel") { (d: Dog) -> Dog in
            print("SUCCESS --- 2-11")
            assert(d.name == dog.name && d.age == dog.age)
            return d
        }

        register("registerModelArrays") { (d: [Dog]) -> [Dog] in
            print("SUCCESS --- 2-10")
            assert(d.count == 3)
            assert(d[0].name == dog.name && d[0].age == dog.age && d[0].something == dog.something)
            return d
        }

            // Test both sending and receiving types
            // Test receiving collections in invocation
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
        
        // Deferreds
//        register("subDeferred") { (a: Int) -> Any in
//            print("SUCCESS --- 3-1")
//            return a
//        }
        
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
//        receiver.publish("subscribeNothing")
//        
//        // Primitive Types
//        receiver.publish("subscribePrimitives", 1, 2.2, 3.3, "4", true)
//        
//        // Arrys of simple types
//        receiver.publish("subscribeArrays", [1, 2], [2.2, 3.3], [4.4, 5.5], ["6", "7"], [true, false])
//
//         receiver.publish("subscribeModel", dog)

//        // Reg/Call Success Cases
//        // No arguments
//        receiver.call("registerNothing").then {
//            assert(true)
//        }
        
        receiver.call("registerModel", dog).then { (d: Dog) in
            assert(d.age == 21)
            print("SUCESS --- 2-12")
        }

//        // Primitive Types
//        receiver.call("registerPrimitives", 1, 2.2, 3.3, "4", true).then { (a: Int, c: Double, d: String, e: Bool) in
//            assert(a == 1)
//            //assert(b == 2.2)
//            assert(c == 3.3)
//            assert(d == "4")
//            assert(e == true)
//            
//            print("SUCCCES --- 2-4")
//        }
//        
//        // Collections of simple types
//        receiver.call("registerArrays", [1, 2], [4.4, 5.5], ["6", "7"], [true, false]).then { (a: [Int], c: [Double], d: [String], e: [Bool]) in
//            assert(a == [1, 2])
//            //assert(b == [2.2, 3.3])
//            assert(c == [4.4, 5.5])
//            assert(d == ["6", "7"])
//            assert(e == [true, false])
//            print("SUCCESS --- 2-7")
//            
//        }.error { reason in
//            // TODO: the reason itself is not given, instead its the class of argument
//            print("FAILURE ON CALL RETURN --- 2-2")
//            print("\tREASON: \(reason)")
//        }
        
        // Collections of model objects
        receiver.call("registerModelArrays", dogs).then { (d: [Dog]) in
            assert(d[0].name == dog.name && d[0].age == dog.age && d[0].something == dog.something)
            print("SUCCESS --- 2-13")
        }.error { reason in
            print("FAILURE ON CALL RETURN --- 2-9")
            print("\tREASON: \(reason)")
        }

//
//        receiver.call("registerSinglePrimitive", 1).then { (a: Int) in
//            assert(a == 1)
//            print("SUCCCES --- 2-6")
//        }
        
//        receiver.call("subDeferred", 1).then { (a: Int) in
//            print("SUCCESS --- 3-2")
//        }.then {
//            print("SUCCESS --- 3-3")
//        }
//        
//        receiver.call("subDeferred", "a").error { reason in
//            print("SUCCESS --- 3-4")
//        }.error { reason in 
//            print("SUCCESS --- 3-5")
//        }
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

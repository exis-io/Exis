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
        subscribe("subscribeNothing") {
            print("SUCCESS --- 1-1")
        }
        
        // Primitive Types
        subscribe("subscribePrimitives") { (a: Int, b: Float, c: Double, d: String, e: Bool) in
            print("SUCCESS --- 1-2")
            assert(a == 1 && b == 2.2 && c == 3.3 && d == "4" && e == true)
        }
        
        // Arrys of simple types
        subscribe("subscribeArrays") { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) in
            print("SUCCESS --- 1-3 ")
            
            assert(a == [1, 2])
            //            assert(b == [2.2, 3.3])
            assert(c == [4.4, 5.5])
            assert(d == ["6", "7"])
            assert(e == [true, false])
        }
        
//        subscribe("subscribeModel") { (d: Dog) in
//            print("SUCESS --- 1-4")
//            assert(d.name == dog.name && d.age == dog.age)
//        }
        
        // TODO: subscribe with model object
        // TODO: Dictionaries of simple types
        // TODO: Any
        
        
        // Reg/Call
        register("registerNothing") {
            print("SUCCESS --- 2-1")
        }
        
        // FAIL with no cumin enforcement present
        register("registerPrimitives") { (a: Int, b: Float, c: Double, d: String, e: Bool) -> (Int, Float, Double, String, Bool) in
            assert(a == 1 && b == 2.2 && c == 3.3 && d == "4" && e == true)
            return (a, b, c, d, e)
        }
        
        register("registerArrays") { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) -> ([Int], [Float], [Double], [String], [Bool]) in
            assert(a == [1, 2] && b == [2.2, 3.3] && c == [4.4, 5.5] && d == ["6", "7"] && e == [true, false])
            return (a, b, c, d, e)
        }
        
        register("registerSinglePrimitive") { (a: Int) -> Int in
            print("SUCCESS --- 2-5")
            assert(a == 1)
            return a
        }
        
        // Riffle Model objects with returns
        register("registerModel") { (d: Dog) -> Dog in
            print("SUCCESS --- 2-11")
            assert(d.name == dog.name && d.age == dog.age)
            return d
        }
        
        //        register("registerModelArrays") { (d: [Dog]) -> [Dog] in
        //            print("SUCCESS --- 2-10")
        //            assert(d.count == 3)
        //            assert(d[0].name == dog.name && d[0].age == dog.age && d[0].something == dog.something)
        //            return d
        //        }
        
        //Test both sending and receiving types
        //Test receiving collections in invocation
        
        //WARNING: cant receive 5 elements in return
        //            receiver.call("registerModelArrays", [Dog(), Dog(), Dog()]).then { (dogs: [Dog]) in
        //                print("\(t) : Call receiving object collection:", dogs)
        //                print("                      expecting: 1 2.0 3.0 4\n")
        //            })
        
        
        joinFinished()
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

class Sender: Domain {
    var receiver: Receiver!
    
    func passingTests() {
        receiver.publish("subscribeNothing")
        
        receiver.publish("subscribePrimitives", 1, 2.2, 3.3, "4", true)
        
        receiver.publish("subscribeArrays", [1, 2], [2.2, 3.3], [4.4, 5.5], ["6", "7"], [true, false])
        
        
        // Reg/Call
        receiver.call("registerNothing").then {
            assert(true)
        }
        
        receiver.call("registerPrimitives", 1, 2.2, 3.3, "4", true).then { (a: Int, b: Float, c: Double, d: String, e: Bool) in
            assert(a == 1 && b == 2.2 && c == 3.3 && d == "4" && e == true)
        }
        
        receiver.call("registerArrays", [1, 2], [2.2, 3.3], [4.4, 5.5], ["6", "7"], [true, false]).then { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) in
            assert(a == [1, 2] && b == [2.2, 3.3] && c == [4.4, 5.5] && d == ["6", "7"] && e == [true, false])
        }.error { reason in
            // TODO: the reason itself is not given, instead its the class of argument
            print("FAILURE ON CALL RETURN --- registerArrays")
            print("\tREASON: \(reason)")
        }
        
    }
    
    override func onJoin() {
        print("Sender joined")
        // passingTests()
        
        
        
        // receiver.publish("subscribeModel", dog)
        //
        //        receiver.call("registerModel", dog).then { (d: Dog) in
        //            assert(d.age == 21)
        //            print("SUCESS --- 2-12")
        //        }
        
        
        // Collections of model objects
        //        receiver.call("registerModelArrays", dogs).then { (d: [Dog]) in
        //            assert(d[0].name == dog.name && d[0].age == dog.age && d[0].something == dog.something)
        //            print("SUCCESS --- 2-13")
        //        }.error { reason in
        //            print("FAILURE ON CALL RETURN --- 2-9")
        //            print("\tREASON: \(reason)")
        //        }
        ////
        //        receiver.call("registerSinglePrimitive", 1).then { (a: Int) in
        //            assert(a == 1)
        //            print("SUCCCES --- 2-6")
        //        }.error { reason in
        //            print("FAIL --- 2-6")
        //            print(reason)
        //        }
        //
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

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
    var joinFinished: (() -> ())
    
    init(name: String, superdomain: Domain, done: () -> ()) {
        joinFinished = done
        super.init(name: name, superdomain: superdomain)
    }
    
    override func onJoin() {
        passingTests()
        
        subscribe("stress") { (a: String) in
            print("Success stress \(a)")
        }
        
        joinFinished()
    }
    
     func passingTests() {
        print("Recever joined")
        
        // Set some non-default values so we can check
        dog.age = 21
        dog.name = "Trump"
        dog.something = 56.4
        
        // Pub Sub
        subscribe("subscribeNothing") {
            print("Success subscribeNothing")
            assert(true)
        }
        
        subscribe("subscribePrimitives") { (a: Int, b: Float, c: Double, d: String, e: Bool) in
            print("Success subscribePrimitives")
            assert(a == 1 && b == 2.2 && c == 3.3 && d == "4" && e == true)
        }
        
        subscribe("subscribeArrays") { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) in
            print("Success subscribeArrays")
            assert(a == [1, 2])
            // assert(b == [2.2, 3.3])
            assert(c == [4.4, 5.5])
            assert(d == ["6", "7"])
            assert(e == [true, false])
        }
        
        // FAIL on double check-- change in precision
        subscribe("subscribeModel") { (d: Dog) in
            print("Success subscribeModel")
            assert(d.name == dog.name && d.age == dog.age)
        }
        
        // This doesnt work! Node doesn't implement it
        subscribe("subscribeOptions", options: Options(details: true)) { (details: Details) in
            print("Success subscribeOptions")
            print("Have Details: \(details.caller)")
        }

        // Reg/Call
        register("registerNothing") {
            print("Success registerNothing")
            assert(true)
        }

        // FAIL with no cumin enforcement present
        register("registerPrimitives") { (a: Int, b: Float, c: Double, d: String, e: Bool) -> (Int, Float, Double, String, Bool) in
            print("Success registerPrimitives")
            assert(a == 1 && b == 2.2 && c == 3.3 && d == "4" && e == true)
            return (a, b, c, d, e)
        }
        
        // FAIL: floats and doubles wrong types
        register("registerArrays") { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) -> ([Int], [Float], [Double], [String], [Bool]) in
            print("Success registerArrays")
            // assert(a == [1, 2] && b == [2.2, 3.3] && c == [4.4, 5.5] && d == ["6", "7"] && e == [true, false])
            assert(a == [1, 2] && d == ["6", "7"] && e == [true, false])
            return (a, b, c, d, e)
        }
        
        register("registerSinglePrimitive") { (a: Int) -> Int in
            print("Success registerSinglePrimitive")
            assert(a == 1)
            return a
        }
        
        register("registerModel") { (d: Dog) -> Dog in
            print("Success registerModel")
            assert(d.name == dog.name && d.age == dog.age)
            return d
        }
        
        register("registerModelArrays") { (d: [Dog]) -> [Dog] in
            print("Success registerModelArrays")
            assert(d.count == 3)
            assert(d[0].name == dog.name && d[0].age == dog.age && d[0].something == dog.something)
            return d
        }
        
        register("regDeferred") { (a: Int) -> Int in
            print("Success regDeferred")
            return a
        }
        
        register("registerOptions", options: Options(details: true)) { (details: Details) in
            print("Success registerOptions")
            print("Have details: \(details.caller)")
        }
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

class Sender: Domain {
    var receiver: Domain
    
    init(name: String, superdomain: Domain, peer: Domain) {
        receiver = peer
        super.init(name: name, superdomain: superdomain)
    }
    
    func passingTests() {
        receiver.publish("subscribeNothing")
        
        receiver.publish("subscribePrimitives", 1, 2.2, 3.3, "4", true)
        
        receiver.publish("subscribeArrays", [1, 2], [2.2, 3.3], [4.4, 5.5], ["6", "7"], [true, false])
        
        receiver.publish("subscribeModel", dog)
        
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

        receiver.call("registerModel", dog).then { (d: Dog) in
           assert(d.age == 21 && d.name == "Trump")
        }

        receiver.call("registerModelArrays", dogs).then { (d: [Dog]) in
           assert(d[0].name == dog.name && d[0].age == dog.age && d[0].something == dog.something)
        }.error { reason in
           print("FAILURE ON CALL RETURN --- 2-9")
           print("\tREASON: \(reason)")
        }

        receiver.call("registerOptions")

        // Deferreds
        // Make sure deferreds correctly chain callbacks
        var firedFirstCallback = false
        receiver.call("regDeferred", 1).then { (a: Int) in
           firedFirstCallback = true
        }.then {
           assert(firedFirstCallback)
        }

        var firedFirstErrback = false
        receiver.call("regDeferred", "a").error { reason in
           firedFirstErrback = true
        }.error { reason in
           assert(firedFirstErrback)
        }
    }
    
    override func onJoin() {
        print("Sender joined")
        passingTests()

        // Stress Testing
        // for _ in 0...50 {
        //    receiver.publish("stress", "asdfasdfasdf")
        // }
        
        print("done")
        
        // Fails- not enforced at the node
        // receiver.publish("subscribeOptions")
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

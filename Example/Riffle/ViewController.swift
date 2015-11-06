//
//  ViewController.swift
//  Riffle
//
//  Created by Mickey Barboi on 09/25/2015.
//  Copyright (c) 2015 Mickey Barboi. All rights reserved.
//

import UIKit
import Riffle

class Dog: RiffleModel {
    var id = -1
    var name = ""
    
    func ini(i: Int, _ n: String) -> Dog {
        id = i
        name = n
        return self
    }
    
    override func description() -> String! {
        return "\(id),\(name)"
    }
}

class ViewController: UIViewController {
    var alpha: AlphaSession?
    var beta: BetaSession?
    
    var isBlinking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setFabric("ws://ubuntu@ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws")
        
        beta = BetaSession(domain: "xs.beta")
        alpha = AlphaSession(domain: "xs.alpha")
        
        alpha!.parent = self
        beta!.parent = self
        
        alpha!.connect()
    }
    
    func alphaFinished() {
        beta!.connect()
    }
    
    func betaFinished() {
        startTests()
    }
    
    // Tests
    func startTests() {
        // Publish/Subscribe
        testPSTypes()
        testPSTypeCollections()
        
        // Primitive Types
        psTypes()
        
        rcTypes(4)
        
        // Riffle Objects
        roObjects(5)
        
        // RiffleObect Collections
        roColletions(6)
        roColletionsNoArg(7)
    }
    
    
    // MARK: Publish/Subscribe
    func testPSTypes() {
        // What kinds of types can be returned
        alpha!.subscribe("xs.alpha/1") { (a: Int, b: Float, c: Double, d: String, e: Bool) in
            print("1 : Sub receiving single types:", a, b, c, d, e)
            print("                     expecting: 1 2.0 3.0 4 true\n")
        }

        beta!.publish("xs.alpha/1", 1, 2.0, 3.0, "4", true)
    }
    
    func testPSTypeCollections() {
        // What kinds of types can be returned
        alpha!.subscribe("xs.alpha/2") { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) in
            print("2 : Sub receiving typed collections:", a, b, c, d, e)
            print("                          expecting: [1, 2] [3.0, 4.0] [5.0, 6.0] [\"7\", \"8\"] [true, false]\n")
        }
        
        beta!.publish("xs.alpha/2", [1, 2], [3.0, 4.0], [5.0, 6.0], ["7", "8"], [true, false])
        
    }
    
    
    // MARK: Single Types
    func psTypes() {
        // Test receiving types in invocation
        
        alpha!.register("xs.alpha/3") { (a: Int, b: Float, c: Double, d: String, e: Bool) in
            print("3 : Register receiving single types:", a, b, c, d, e)
            print("                     expecting: 1 2.0 3.0 4 true\n")
        }
        
        beta!.call("xs.alpha/3", 1, 2.0, 3.0, "4", true, handler: nil)
    }
    
    func rcTypes(t: Int) {
        // Test both sending and receiving types
        // Test receiving collections in invocation
        alpha!.register("xs.alpha/\(t)") { (a: Int, b: Float, c: Double, d: String, e: Bool) -> AnyObject in
            print("\(t) : Register receiving single types:", a, b, c, d, e)
            print("                          expecting: 1 2.0 3.0 4 true\n")
            return [a, b, c, d]
        }
        
        // WARNING: cant receive 5 elements in return
        
        beta!.call("xs.alpha/\(t)", 1, 2.0, 3.0, "4", true, handler: { (a: Int, b: Float, c: Double, d: String) in
            print("\(t) : Call receiving single types:", a, b, c, d)
            print("                      expecting: 1 2.0 3.0 4\n")
        })
    }
    
    
    // MARK: Object Returns
    func roObjects(t: Int) {
        let dog = Dog().ini(1, "1")
        
        // Test both sending and receiving types
        // Test receiving collections in invocation
        
        alpha!.register("xs.alpha/\(t)") { (d: Dog) -> AnyObject in
            print("\(t) : Register receiving object:", d)
            print("                       expecting: \(dog)\n")
            return d
        }
        
        beta!.call("xs.alpha/\(t)", Dog().ini(1, "1"), handler: { (d: Dog) in
            print("\(t) : Call receiving object:", d)
            print("                   expecting: \(dog)\n")
        })
    }
    
    
    // MARK: Object Collections
    func roColletions(t: Int) {
        // WARNING: Cant accept collections and return something!
        
        //let dogs = [Dog(1, "1"), Dog(1, "1"), Dog(1, "1")]
        
        // Test both sending and receiving types
        // Test receiving collections in invocation
        /*
        alpha!.register("xs.alpha/\(t)") { (d: [Dog]) -> AnyObject in
            print("\(t) : Register receiving model object:", d.count)
            print("                          expecting: \(dogs.count)\n")
            return d
        }
        
        // WARNING: cant receive 5 elements in return
        
        beta!.call("xs.alpha/\(t)", [Dog(), Dog(), Dog()], handler: { (dogs: [Dog]) in
            print("\(t) : Call receiving object collection:", dogs)
            print("                      expecting: 1 2.0 3.0 4\n")
        })
        */
    }
    
    func roColletionsNoArg(t: Int) {
        // WARNING: Cant accept collections and return something!
        
        let dogs = [Dog().ini(1, "1"), Dog().ini(2, "1"), Dog().ini(3, "1")]
        
        // Test both sending and receiving types
        // Test receiving collections in invocation
        
        alpha!.register("xs.alpha/\(t)") { (s: String) -> AnyObject in
            return [dogs]
        }
        
        beta!.call("xs.alpha/\(t)", "string", handler: { (dogs: [Dog]) in
            print("\(t) : Call receiving object collection:", dogs.count)
            print("                            expecting: 3\n")
        })

    }
    
    
    
    func testRCCallTypes() {
        // Test recieving types from call result
    }
    
    func testRCCallTypeCollections() {
        // Test recieving collections from call result
    }
    

    
    func testRCRegisterCallTypeCollections() {
        // Test both sending and receiving collections
    }
    
    /*
    // This DOES NOT WORK: all return types have to be AnyObject or nothing!
    func returnCollections() -> (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool])  {
        return ([1, 2], [1.0, 2.0], [3.0, 4.0], ["Hey!", "There!"], [true, false])
    }
    */
}


class AlphaSession: RiffleSession {
    var parent: ViewController?
    
    override func onJoin() {
        parent!.alphaFinished()
    }
    
    
    
    
}

class BetaSession: RiffleSession {
    var parent: ViewController?
    
    override func onJoin() {
        parent!.betaFinished()
        
        // Testing sending all kinds of types
        //publish("xs.alpha/types", 1, 2.0, 3.0, "4", true)
        
        // Testing sending collections of all kinds of types
        //publish("xs.alpha/collections", [1, 2], [3.0, 4.0], [5.0, 6.0], ["7", "8"], [true, false])
        
        // Fails: too many args in call return
        //call("xs.alpha/callType", 1, 2.0, 3.0, "4", true)  { (a: Int, b: Float, c: Double, d: String, e: Bool ) in
        //    print("4 : Call receiving single types:", a, b, c, d, e)
        //    print("                      expecting: 1 2.0 3.0 4 true\n")
        //}

        // Fails: number of args
        //call("xs.alpha/callType")  { (a: Int, b: Float, c: Double, d: String) in
        //    print("4 : Call receiving single types:", a, b, c, d)
        //    print("                      expecting: 1 2.0 3.0 4\n")
        //}
        
        //Testing return of many model objects
        //call("xs.alpha/callType") { (dogs: [Dog]) in
        //    print("Received \(dogs.count) dogs")
        //}
    }
}
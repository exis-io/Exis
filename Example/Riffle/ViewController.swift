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

func ==(lhs: Dog, rhs: Dog) -> Bool {
    return lhs.id == rhs.id
}

class AlphaSession: RiffleAgent {
    var parent: ViewController?
    var connected = false
    
    override func onJoin() {
        print("\(domain) joined")
        connected = true
        parent!.connections()
    }
}

class BetaSession: RiffleAgent {
    var parent: ViewController?
    var connected = false
    
    override func onJoin() {
        print("\(domain) joined")
        connected = true
        parent!.connections()
    }
}


class ViewController: UIViewController {
    var app: RiffleAgent?
    var alpha: AlphaSession?
    var beta: BetaSession?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rifflog.DEBUG = true
        setFabric("ws://ubuntu@ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws")
        
        alpha = AlphaSession(domain: "xs.tester.alpha")
        beta = BetaSession(domain: "xs.tester.beta")
        
        alpha?.parent = self
        beta?.parent = self
        
        alpha?.connect()
        beta?.connect()
        
        //app = RiffleAgent(domain: "xs.tester")
        //alpha = AlphaSession(name: "alpha", superdomain: app!)
        //beta = BetaSession(name: "beta", superdomain: app!)
        //app!.connect()
    }
    
    func connections() {
        if alpha!.connected && beta!.connected {
            print("Starting tests")
            startTests()
        }
    }
    

    // Tests
    func startTests() {
        
        // Publish/Subscribe
        testPSTypes(1)
        testPSTypeCollections(2)
        
        // Primitive Types
        rcTypes(3)
        
        // Riffle Objects
        roObjects(4)
        
        // RiffleObect Collections
        roColletions(5)
        roColletionsNoArg(6)
    }
    
    
    // MARK: Publish/Subscribe
    func testPSTypes(t: Int) {
        // What kinds of types can be returned
        alpha!.subscribe("\(t)") { (a: Int, b: Float, c: Double, d: String, e: Bool) in
            print("1 : Sub receiving single types:", a, b, c, d, e)
            
            assert(a == 1)
            assert(b == 2.2)
            assert(c == 3.3)
            assert(d == "4")
            assert(e == true)
        }

        beta!.publish("xs.tester.alpha/\(t)", 1, 2.2, 3.3, "4", true)
    }
    
    func testPSTypeCollections(t: Int) {
        // What kinds of types can be returned
        alpha!.subscribe("\(t)") { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) in
            //print("Received: \(a) \(b) \(c) \(d) \(e), expecting 1 2.2 3.3 4 true")
            
            assert(a == [1, 2])
            assert(b == [2.2, 3.3])
            assert(c == [4.4, 5.5])
            assert(d == ["6", "7"])
            assert(e == [true, false])
        }
        
        beta!.publish("xs.tester.alpha/\(t)", [1, 2], [2.2, 3.3], [4.4, 5.5], ["6", "7"], [true, false])
        
    }
    
    
    // MARK: Single Types
    func rcTypes(t: Int) {
        
        // Test both sending and receiving types
        // Test receiving collections in invocation
        alpha!.register("\(t)") { (a: Int, b: Float, c: Double, d: String, e: Bool) -> AnyObject in
            //print("Received: \(a) \(b) \(c) \(d) \(e), expecting 1 2.2 3.3 4 true")
            
            assert(a == 1)
            assert(b == 2.2)
            assert(c == 3.3)
            assert(d == "4")
            assert(e == true)
            
            return [a, b, c, d, e]
        }
        
        // WARNING: cant receive 5 elements in return
        
        beta!.call("xs.tester.alpha/\(t)", 1, 2.2, 3.3, "4", true, handler: { (a: Int, b: Float, c: Double, d: String) in
            assert(a == 1)
            assert(b == 2.2)
            assert(c == 3.3)
            assert(d == "4")
            //assert(e == true)
        })
    }
    
    
    // MARK: Object Returns
    func roObjects(t: Int) {
        let dog = Dog().ini(1, "2")
        
        // Test both sending and receiving types
        // Test receiving collections in invocation
        
        alpha!.register("\(t)") { (d: Dog) -> AnyObject in
            //print("Recieved:\(d), expecting: \(dog)")
            assert(d == dog)
            return d
        }
        
        beta!.call("xs.tester.alpha/\(t)", dog, handler: { (d: Dog) in
            //print("\(t) Recieved\(d), expecting \(dog)")
            assert(d == dog)
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
        
        alpha!.register("\(t)") { (s: String) -> AnyObject in
            return [dogs]
        }
        
        beta!.call("xs.tester.alpha/\(t)", "string", handler: { (d: [Dog]) in
            //print("\(t) : Call receiving object collection:", dogs.count)
            assert(dogs == d)
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
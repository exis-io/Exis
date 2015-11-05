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
        alpha!.connect()
    }
    
    func alphaFinished() {
        beta!.connect()
    }
}


class AlphaSession: RiffleSession {
    var parent: ViewController?
    
    
    override func onJoin() {
        subscribe("xs.alpha/types", receiveTypes)
        subscribe("xs.alpha/collections", recieveCollections)
        
        register("xs.alpha/callType", returnTypes)
        
        // Testing return of Model Collections
        
        parent!.alphaFinished()
    }
    
    
    // MARK: Receivers
    func receiveTypes(a: Int, b: Float, c: Double, d: String, e: Bool) {
        print("1 : Sub receiving single types:", a, b, c, d, e)
        print("                 expecting: 1 2.0 3.0 4 true\n")
    }
    
    func recieveCollections(a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) {
        print("2 : Sub receiving typed collections:", a, b, c, d, e)
        print("                      expecting: [1, 2] [3.0, 4.0] [5.0, 6.0] [\"7\", \"8\"] [true, false]\n")
    }
    
    func returnTypes(a: Int, b: Float, c: Double, d: String, e: Bool) -> AnyObject {
        print("3 : Register receiving single types:", a, b, c, d, e)
        print("                          expecting: 1 2.0 3.0 4 true\n")
        return [a, b, c, d]
    }
    
    // This DOES NOT WORK: all return types have to be AnyObject or nothing!
    func returnCollections() -> (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool])  {
        return ([1, 2], [1.0, 2.0], [3.0, 4.0], ["Hey!", "There!"], [true, false])
    }
    
    func returnModelCollections(name: String) -> [AnyObject] {
        return [Dog(), Dog(), Dog()]
    }
}

class BetaSession: RiffleSession {
    
    override func onJoin() {
        // Testing sending all kinds of types
        //publish("xs.alpha/types", 1, 2.0, 3.0, "4", true)
        
        // Testing sending collections of all kinds of types
        //publish("xs.alpha/collections", [1, 2], [3.0, 4.0], [5.0, 6.0], ["7", "8"], [true, false])
        
        // Testing call and return for all kinds of types
        // WARNING: cant receive 5 elements in return
        call("xs.alpha/callType", 1, 2.0, 3.0, "4", true)  { (a: Int, b: Float, c: Double, d: String) in
            print("4 : Call receiving single types:", a, b, c, d)
            print("                      expecting: 1 2.0 3.0 4\n")
        }
        
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
        call("xs.alpha/callType") { (dogs: [Dog]) in
            print("Received \(dogs.count) dogs")
        }
    }
}
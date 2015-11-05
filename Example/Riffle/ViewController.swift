//
//  ViewController.swift
//  Riffle
//
//  Created by Mickey Barboi on 09/25/2015.
//  Copyright (c) 2015 Mickey Barboi. All rights reserved.
//

import UIKit
import Riffle

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
        print("Alpha joined")
        
        subscribe("xs.alpha/types", receiveTypes)
        subscribe("xs.alpha/collections", recieveCollections)
        register("xs.alpha/callType", returnTypes)
        
        parent!.alphaFinished()
    }
    
    
    // MARK: Receivers
    func receiveTypes(a: Int, b: Float, c: Double, d: String, e: Bool) {
        print("Receiving single types: ", a, b, c, d, e)
    }
    
    func recieveCollections(a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) {
        print("Receiving all kinds of stuff: ", a, b, c, d, e)
    }
    
    func returnTypes() -> AnyObject {
        print("Returning bunch of types")
        return [1, "Hey!", true]
    }
    
    // This DOES NOT WORK: all return types have to be AnyObject or nothing!
    func returnCollections() -> (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool])  {
        return ([1, 2], [1.0, 2.0], [3.0, 4.0], ["Hey!", "There!"], [true, false])
    }
}

class BetaSession: RiffleSession {
    
    override func onJoin() {
        print("Beta joined")
        
        // Testing sending all kinds of types
        publish("xs.alpha/types", 1, 2.0, 3.0, "4", true)
        
        // Testing sending collections of all kinds of types
        publish("xs.alpha/collections", [1, 2], [3.0, 4.0], [5.0, 6.0], ["7", "8"], [true, false])
        
        // Testing call and return for all kinds of types
        call("xs.alpha/callType") { (a: Int, b: String, c: Bool) in
            print("Beta: callType returned \(a), \(b), \(c)")
        }
    }
}
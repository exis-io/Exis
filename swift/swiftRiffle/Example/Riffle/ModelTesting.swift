//
//  ModelTesting.swift
//  Riffle
//
//  Created by damouse on 4/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Riffle

class Cat: Model {
    var name = "Spot"
    var age = 43
    var something: Double = 1.0
}


class Modeler: Domain {
    var loadedCats: [Cat] = []
    
    override func onJoin() {
        
        // How many objects do we have?
//        Cat.count().then { (number: Int) in
//            print("Count: \(number)")
//        }
        
        // Load all saved cats
//        Cat.all().then { (cats: [Cat]) in
//            print("All cats: #\(cats.count)")
//            for c in cats { print(c.description) }
//        }
//        
//        // Find all models that match the given query
//        // In other words: get all cats where cat.name == "Spot"
        
        Cat.find(["name": "Spot"]).then { (cats: [Cat]) in
            print("Found: \(cats.count)")
            for c in cats { print(c.description, c._xsid) }
        }
        
        // Create a single new model object
//        let c = Cat()
//        c.name = "Bill"
//        
//        c.create().then {
//            
//            // Find the cat that was just created to double-check it worked
//            Cat.find(["name": "Bill"]).then { (cats: [Cat]) in
//                print("Found: \(cats.count)")
//                for c in cats { print(c.description, c._xsid) }
//            }
//            
//            // Update a saved cat
//            c.age = 600
//            c.save().then {
//                // Find the cat that was just created to double-check it worked
//                Cat.find(["name": "Bill"]).then { (cats: [Cat]) in
//                    print("Found: \(cats.count)")
//                    
//                    for c in cats { print(c.description, c._xsid) }
//                }
//            }
//        }
    }
}
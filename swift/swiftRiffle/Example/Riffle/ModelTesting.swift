//
//  ModelTesting.swift
//  Riffle
//
//  Created by damouse on 4/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Riffle

class Panther: Model {
    var name = "Spot"
    var age = 43
    var something: Double = 1.0
    
    convenience init(name: String) {
        self.init()
        
        self.name = name
    }
}


class Modeler: Domain {
    var loadedCats: [Panther] = []
    
    override func onJoin() {
        
        var count = 0
        // How many objects do we have?
        Panther.count().then { (number: Int) in
            print("Count: \(number)")
            count = number
        }
        
        // Load all the cats
        Panther.all().then { (cats: [Panther]) in
            print("All cats: #\(cats.count)")
            for c in cats { print(c.description) }
        }

        
        
        // Find all models that match the given query
        // In other words: get all cats where cat.name == "Spot"
        Panther.find(["name": "Spot"]).then { (cats: [Panther]) in
            logCats(cats)

            // Update a saved cat
            let updating = cats[0]
            updating.age = 600
            updating.save().then {
                // Find the cat that was just created to double-check the save succeeded
                Panther.find(["age": 600]).then { (cats: [Panther]) in
                    logCats(cats)
                }
            }.error { reason in
                print("Save failed: \(reason)")
            }
        }
        
        
        Panther.find(["name": "Till"]).then { (cats: [Panther]) in
            
            cats[0].age = 900
            cats[0].save().then {
                Panther.find(["age": 900]).then { (cats: [Panther]) in
                    logCats(cats)
                    }.error { error in
                        print(error)
                }
            }
        }
        
        
        // Create a single new model object
        let c = Panther()
        c.name = "Till"
        
        c.create().then {
            
            // Find the cat that was just created to double-check it worked
            Panther.find(["name": "Till"]).then { (cats: [Panther]) in
                logCats(cats)
                
                cats[0].age = 900
                cats[0].save().then {
                    Panther.find(["age": 900]).then { (cats: [Panther]) in
                        logCats(cats)
                    }.error { error in
                        print(error)
                    }
                }
            }

        
            // Update a saved cat
            c.age = 600
            c.save().then {
                
                // Find the cat that was just created to double-check it worked
                Panther.find(["name": "Bill"]).then { (cats: [Panther]) in
                    print("Found: \(cats.count)")
                    
                    for c in cats { print(c.description, c._xsid) }
                }
                
            }
        }
    
        
        // Find the cat that was just created to double-check it worked
        Panther.find(["name": "Bill"]).then { (cats: [Panther]) in
            logCats(cats)

            let c = cats[0]
            print("ID: \(c._xsid) \(Double(c._xsid))")
            
            // Update a saved cat
            c.age = 600
            c.save().then {
                print("Saved")
                
                // Look for cats that match that age to double-check the save worked
                Panther.find(["age": 600]).then { (cats: [Panther]) in
                    logCats(cats)
                }.error { error in
                    print(error)
                }
            }
        }
        
        
        // Destroy an object
        Panther.all().then { (cats: [Panther]) in
            logCats(cats)
            
            cats[0].destroy().then {
                Panther.count().then { (number: Int) in
                    print("Had \(count), now have \(number)") // The count should have gone down by one!
                }
            }
        }
       
        
        // Creating multiple models at once
        let jungle = [Panther(name: "Anna"), Panther(name: "Beatrice"), Panther(name: "Caroline")]
        
        jungle.create().then {
            Panther.count().then { (number: Int) in
                print("Have \(number))")
            }
        }
        
        
        // Destroying collections of models
        Panther.all().then { (cats: [Panther]) in
            logCats(cats)

            cats.destroy().then {
                Panther.count().then { (number: Int) in
                    print("Destoryed all the cats, have: \(count)") // The count should have gone down by one!
                }
            }
        }
        
        
        // Saving lots of models at once
        let savannah = [Panther(name: "Anna"), Panther(name: "Beatrice"), Panther(name: "Caroline")]

        savannah.create().then {
            for cat in jungle { cat.age = 1000 }
            
            savannah.save().then() {
                Panther.find(["age": 1000]).then { (cats: [Panther]) in
                    logCats(cats)
                }
            }
        }
        
    }
}

func logCats(cats: [Panther]) {
    print("\nFound: \(cats.count)")
    for c in cats { print("\t", c.description, c._xsid) }
}
























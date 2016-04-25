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
    
    override func onJoin() {
        print("Modeler joined")
        Riffle.setLogLevelDebug()

        Cat.count().then { (number: Int) in
            print("Have \(number) cats")
        }.error { reason in
            print("An error occured: \(reason)")
        }
    }
}
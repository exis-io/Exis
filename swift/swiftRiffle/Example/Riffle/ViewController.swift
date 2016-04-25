//
//  ViewController.swift
//  Riffle
//
//  Created by Damouse on 09/25/2015.
//  Copyright (c) 2015 Mickey Barboi. All rights reserved.
//

import UIKit
import Riffle

class Rat: Model {
    var name = "Joe"
    //    var age = 100
}

    

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        letdmtest(Rat.self)

//        Riffle.setFabricDev()
//        
//        // This is faking two seperate connections by creating two AppDomains. This is not intended for user functionality
//        let app2 = AppDomain(name: "xs.tester")
//        let receiver2 = Domain(name: "receiver", superdomain: app2)
//        let sender2 = Sender(name: "sender", superdomain: app2, peer: receiver2)
//        
//        let app = AppDomain(name: "xs.tester")
//        let receiver = Receiver(name: "receiver", superdomain: app, done: {
//            app2.login("sender")
//        })
//        
//        app.login("receiver")
    }
}

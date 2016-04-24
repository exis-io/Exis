//
//  main.swift
//  Backend
//
//  Created by damouse on 3/7/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Riffle

// Change me to change the current set of inline tests
enum Test { case Auth0, Auth1, Domain, Model }
let CURRENTTEST = Test.Auth0

// Required helper method for OSX backends
initTypes(External(String.self, String.self), External(Int.self, Int.self), External(Double.self, Double.self), External(Float.self, Float.self), External(Bool.self, Bool.self), External(Model.self, Model.self))

Riffle.setLogLevelDebug()

switch CURRENTTEST {
    
    
case .Auth0:
    let app = AppDomain(name: "xs.demo.damouse.auth0test")
    
    // Auth 0 without a domain
//    app.login().then { (domain: String) in
//        print("Successfully connected as ", domain)
//    }.error { reason in
//        print("Login failed: ", reason)
//    }
//    
    // Auth 0 with a domain
    app.login("asdfasdf").then { (domain: String) in
        print("Successfully connected as ", domain)
    }.error { reason in
        print("Login failed: ", reason)
    }
//
//    // Auth 0 resuming a connection
//    app.login("asdfasdf").then { (domain: String) in
//        print("Successfully connected as ", domain)
//    }.error { reason in
//        print("Login failed: ", reason)
//    }
//    
    app.listen()
    

case .Auth1:
    let app = AppDomain(name: "xs.demo.damouse.auth1test")
    
    app.registerAccount("bananas", email: "asdf@gmail.com", password: "123456789").then {
        print("Registration succeeded")
    }.error { reason in
        print("Registration failed \(reason)")
    }
    
    app.listen()

    
case .Domain:
    Riffle.setFabricDev()
    
    // This is faking two seperate connections by creating two AppDomains. This is not intended for user functionality
    let app2 = AppDomain(name: "xs.tester")
    let receiver2 = Domain(name: "receiver", superdomain: app2)
    let sender2 = Sender(name: "sender", superdomain: app2, peer: receiver2)
    
    let app = AppDomain(name: "xs.tester")
    let receiver = Receiver(name: "receiver", superdomain: app, done: {
        app2.login("sender")
    })
    
    app.login("receiver")
    
    app.listen()

    
default:
    break
}













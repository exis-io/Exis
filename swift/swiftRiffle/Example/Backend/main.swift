//
//  main.swift
//  Backend
//
//  Created by damouse on 3/7/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Riffle



enum Test { case Auth0, Auth1, Domain, Model, OsxBugs}
let CURRENTTEST = Test.OsxBugs  // Change me to change the current set of inline tests

// Required helper method for OSX backends
initTypes(External(String.self, String.self), External(Int.self, Int.self), External(Double.self, Double.self), External(Float.self, Float.self), External(Bool.self, Bool.self), External(Model.self, Model.self))

class Caster: ExternalCaster {
    func recode<A, T>(a: A, t: T.Type) -> T { return unsafeBitCast(a, T.self) }
    func recodeString(a: String) -> String { return unsafeBitCast(a, String.self) }
}

caster = Caster()
Riffle.setLogLevelInfo()


switch CURRENTTEST {

case .Auth0:
    // The name you'd like to login as
    let name = "asdfasdf"
    
    // Your app's name, as set at exis.io
    let app = AppDomain(name: "xs.demo.damouse.auth0test")
    
    // If a login attempt in the past succeeded then reconnect will connect with that information
    // The domain name used in that login is returned to you immediately
    app.reconnect().then { (domain: String) in
        print("Successfully reconnected as ", domain)
    }.error { reason in
        
        // Reconnection failed, most likely because there wasn't a saved connection. Lets try a login
        app.login(name).then {
            print("Successfully connected as ", name)
        }.error { reason in
            print("Login failed: ", reason)
        }
    }
    
    // Run forever. Only needed on backends.
    app.listen()
    

case .Auth1:
    // User credentials
    let name = "asdfasdf"
    let password = "12345678"
    let email = "\(name)@gmail.com"
    
    // Your app's name, as set at exis.io
    let app = AppDomain(name: "xs.demo.damouse.auth1test")
    
    // Checking if the user logged in before and is reconnecting
    // If a connection to the fabric was successfully made in the past this resumes it
    // use this to check if the app's user can be logged in right now
    app.reconnect().then { (domain: String) in
        print("Successfully reconnected as ", domain)
    }.error { reason in
        print("Unable to reconnect")
    }
    
    // Logging in
    app.login(name, password: password).then {
        print("Successfully connected as ", name)
    }.error { reason in
        print("Login failed: ", reason)
    }
    
    // Registering
    app.registerAccount(name, email: email, password: password).then {
        print("Successfully connected as ", name)
    }.error { reason in
        print("Login failed: ", reason)
    }

    // Run forever. Only needed on backends.
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

    
case .Model:
    let app = AppDomain(name: "xs.demo.damouse.model")
    let modeler = Modeler(name: "moeerning", superdomain:app)
    
    app.reconnect().error { reason in
        app.login("moeerning").error { reason in
            print("Login failed: ", reason)
        }
    }

    app.listen()
    

// Manual testing for the OSX Types bug
case .OsxBugs:
    OsxBugPlayground().test()
    

}













//
//  App.swift
//  Pods
//
//  Created by damouse on 3/7/16.
//
//

import Foundation
import Mantle

public class AppDomain: Domain {
    public init(name: String) {
        super.init(name: name, app: CoreApp(name: name))
        
        // Kick off the session receive loop if it isn't already started
        // TODO: figure out threading implementation for Ubuntu
        if !Session.receiving {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                Session.receive()
            })
        }
    }
    
    // If a previous session was suspended attempt to log back in with those same credentials
    public func reconnect() -> Deferred {
        let d = Deferred()
        
        defer {
            d.errback(["No saved session found."])
            d.destroy()
        }
        
        return d
    }
    
    // Close the connection
    public func disconnect() {
        app.callCore("Close", ["AppDomain closing"])
    }
    
    // Login domain is the target domain for this session
    public func login(name: String? = nil, password: String? = nil) -> Deferred {
        var args: [String] = []
        
        if let n = name {
            args.append(n)
        }
        
        if let p = password {
            args.append(p)
        }
        
        // TODO: call and save GetToken and after a successful login and register
        return app.callCore("BetterLogin", args)
    }
    
    public func register(name: String, email: String, password: String) -> Deferred {
        return app.callCore("BetterRegister", [name, password, email, name])
    }
    
    public func setToken(token: String) {
        app.callCore("SetToken", [token])
    }
    
    // Block until the connection is closed. Only call this on backends!
    public func listen() {
        NSRunLoop.currentRunLoop().run()
    }
}

// Internal App object
class CoreApp: CoreClass {
    init(name: String) {
        super.init()
        initCore("App",[name])
    }
}

/*
 The Auth api
 
 // Represents the connection in addition to the domain itself
 app = AppDomain(name: "xs.test")
 you = Domain(name: "alpha", superdomain: app)
 
 // myName comes back as a string
 // join checks persistence for a token then presents it to the fabric. Fails if the
 // token can't be found or the fabric rejects the token
 app.join().then { myName: String
 let me = Domain(myDomain, superdomain: app)
 
 // Blocks and runs the reactor loop
 app.listen()
 
 }.error {
 // Username and password is obtained from some input source-- ui, cli prompt, etc
 let username = "someUsernameFromInput"
 let password = "somePasswordFromInput"
 
 // Attempt to obtain a token to auth on the fabric. Returns the name of this domain
 // If the login  succeeded the token is persisted under the name presented when the
 // login request was started
 app.login("sender", username, password).then { myName: String
 me= Domain(myDomain, superdomain: app)
 app.listen()
 
 // Returns whatever error the Auth appliance returned as a string
 }.error { reason: String
 print("reason: \(reason)") // Waiting on email...
 }
 
 // Attempt to register with the given credentials.
 // If the login  succeeded the token is persisted under the name presented when the
 // login request was started
 app.register("sender", username, password).then { myDomain in
 me = Domain(myDomain, superdomain: app)
 app.listen()
 
 }.error { reason in
 print(reason) // Username taken, password too short
 }
 }
 */

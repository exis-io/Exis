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
        app.callCore("Close", args: ["AppDomain closing"])
    }
    
    // Login domain is the target domain for this session
    public func login(name: String? = nil, password: String? = nil) -> OneDeferred<String> {
        var args: [String] = []
        
        if let n = name {
            args.append(n)
        }
        
        if let p = password {
            args.append(p)
        }
        
        // TODO: call and save GetToken and after a successful login and register
        let d = TwoDeferred<String, String>()
        let r = OneDeferred<String>()
        
        app.callCore("Login", deferred: d, args: [args])
        
        d.then { token, domain in
            // Save the token and domain for future logins
            
            // Connect to the fabric
            self.app.callCore("Connect").then {
                let subbed  = self.name + "."
                r.callback([domain.stringByReplacingOccurrencesOfString(subbed, withString: "")])
            }.error { reason in
                r.errback([reason])
            }
        }.error { reason in r.errback([reason]) }
        
        return r
    }
    
    public func registerAccount(name: String, email: String, password: String) -> Deferred {
        let d = Deferred()
        
        app.callCore("Register", args: [name, password, email, name]).then {
            self.login(name, password: password).then {
                d.callback([])
            }.error { reason in
                d.errback([reason])
            }
        }.error { reason in
            d.errback([reason])
        }
        
        return d
    }
    
    public func setToken(token: String) {
        app.callCore("SetToken", args: [token])
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

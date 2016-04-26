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
    public func reconnect() -> OneDeferred<String> {
        let d = OneDeferred<String>()
        
        // Check and see if there's a last session saved
        if let domain = Riffle.load(SUSPENDED_DOMAIN), token = Riffle.load(SUSPENDED_TOKEN) {
            app.callCore("SetToken", args: [token])
            app.callCore("SetAgent", args: [domain])
            
            self.app.callCore("Connect").then { () -> () in
                // "Static" initialization for all models and model connections
                if !Model.ready() {
                    Model.setConnection(self)
                }
                
                let subbed  = self.name + "."
                d.callback([domain.stringByReplacingOccurrencesOfString(subbed, withString: "")])
            }.error { reason in
                d.errback([reason])
            }
            
        } else {
            d.errback(["No connection information stored. Connection information is only stored after a successful login"])
        }
        
        return d
    }
    
    // Close the connection
    public func disconnect() {
        app.callCore("Close", args: ["AppDomain closing"])
    }
    
    // Attempt to login and connect with the given credentials. If successful the connection is automatically opened
    public func login(name: String, password: String? = nil) -> Deferred {
        var args: [String] = [name]
        
        if let p = password {
            args.append(p)
        }
        
        // TODO: check for saved tokens for the given domain name and re-use that token as appropriate
        
        let d = TwoDeferred<String, String>()
        let r = Deferred()
        app.callCore("Login", deferred: d, args: [args])
        
        d.then { token, domain in
            self.app.callCore("Connect").then { () -> () in
                // "Static" initialization for all models and model connections
                if !Model.ready() {
                    Model.setConnection(self)
                }
                
                Riffle.save(SUSPENDED_DOMAIN, value: domain)
                Riffle.save(SUSPENDED_TOKEN, value: token)
                Riffle.save(name, value: token)
                
                r.callback([])
            }.error { reason in
                r.errback([reason])
            }
        }.error { reason in
            r.errback([reason])
        }
        
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









//
//  Agent.swift
//  Pods
//
//  Created by Mickey Barboi on 11/7/15.
//
//

import Foundation

public class RiffleAgent: NSObject, RiffleDelegate {
    public var name: String?
    public var domain: String
    public var delegate: RiffleDelegate?
    
    var connection: RiffleConnection
    var superdomain: RiffleAgent?
    
    var registrations: [String] = []
    var subscriptions: [String] = []
    
    
    // MARK: Initialization
    public init(domain d: String) {
        // Initialize this agent as the Application domain, or the root domain
        // for this instance of the application
        
        domain = d
        connection = RiffleConnection()
        name = d
        
        super.init()
        delegate = self
    }
    
    public init(name n: String, superdomain s: RiffleAgent) {
        // Initialize this agent as a subdomain of the given domain. Does not
        // connect. If "connect" is called on either the superdomain or this domain
        // both will be connected
        
        superdomain = s
        domain = s.domain + "." + n
        connection = s.connection
        name = n
        
        super.init()
        delegate = self
        connection.addAgent(self)
    }
    
    deinit {
        //Riffle.debug("\(domain) going down")
        //self.leave()
    }
    
    public func join(token: String? = nil) -> RiffleAgent {
        // Connect this agent and any agents connected to this one
        // superdomains and subdomains
        
        connection.addAgent(self)
        
        if superdomain != nil && superdomain!.connection.open {
            superdomain!.join(token)
        } else {
            connection.connect(self, token: token)
        }
        
        return self
    }
    
    public func leave() {
        _ = registrations.map { self.unregister($0) }
        _ = subscriptions.map { self.unsubscribe($0) }
    }
    
    
    // MARK: Real Calls
    func _subscribe(action: String, fn: ([AnyObject]) throws -> ()) {
        let endpoint = makeEndpoint(action)
        Riffle.debug("\(domain) SUB: \(endpoint)")
        
        connection.session!.subscribe(endpoint, onEvent: { (event: MDWampEvent!) -> Void in
            do {
                try fn(event.arguments)
            } catch CuminError.InvalidTypes(let expected, let recieved) {
                Riffle.warn(": cumin unable to convert: expected \(expected) but received \"\(recieved)\"[\(recieved.dynamicType)] for function \(fn) subscribed at endpoint \(endpoint)")
            } catch {
                Riffle.panic(" Unknown exception!")
            }
            
            })
            { (err: NSError!) -> Void in
                if let e = err {
                    print("An error occured: ", e)
                } else {
                    self.subscriptions.append(endpoint)
                }
        }
    }
    
    func _register(action: String, fn: ([AnyObject]) throws -> ()) {
        let endpoint = makeEndpoint(action)
        Riffle.debug("\(domain) REG: \(endpoint)")
        
        connection.session!.registerRPC(endpoint, procedure: { (wamp: MDWamp!, invocation: MDWampInvocation!) -> Void in
            
            Riffle.debug("INVOCATION: \(endpoint)")
            
            do {
                try fn(invocation.arguments)
            } catch CuminError.InvalidTypes(let expected, let recieved) {
                Riffle.warn(": cumin unable to convert: expected \(expected) but received \"\(recieved)\"[\(recieved.dynamicType)] for function \(fn) registered at endpoint \(endpoint)")
            } catch {
                Riffle.panic(" Unknown exception!")
            }
            
            wamp.resultForInvocation(invocation, arguments: [], argumentsKw: [:])
            
            }, cancelHandler: { () -> Void in
                print("Register Cancelled!")
            })
            { (err: NSError!) -> Void in
                if err != nil {
                    print("Error registering endoint: \(endpoint), \(err)")
                } else {
                    self.registrations.append(endpoint)
                }
        }
    }
    
    func _register<R>(action: String, fn: ([AnyObject]) throws -> (R)) {
        let endpoint = makeEndpoint(action)
        Riffle.debug("\(domain) REG: \(endpoint)")
        
        connection.session!.registerRPC(endpoint, procedure: { (wamp: MDWamp!, invocation: MDWampInvocation!) -> Void in
            var result: R?
            
            Riffle.debug("INVOCATION: \(endpoint)")
            
            do {
                result = try fn(invocation.arguments)
                
                if let r = result as? AnyObject {
                    let serialized = try serialize(r)
                    wamp.resultForInvocation(invocation, arguments: serialized, argumentsKw: [:])
                }
            } catch CuminError.InvalidTypes(let expected, let recieved) {
                Riffle.warn(": cumin unable to convert: expected \(expected) but received \"\(recieved)\"[\(recieved.dynamicType)] for function \(fn) registered at endpoint \(endpoint)")
                result = nil
            } catch {
                Riffle.panic(" Unknown exception!")
            }
            
//            if let autoArray = result as? [AnyObject] {
//                wamp.resultForInvocation(invocation, arguments: serialize(autoArray), argumentsKw: [:])
//            } else {
//                wamp.resultForInvocation(invocation, arguments: serialize([result as! AnyObject]), argumentsKw: [:])
//            }
            
            }, cancelHandler: { () -> Void in
                print("Register Cancelled!")
            })
            { (err: NSError!) -> Void in
                if err != nil {
                    print("Error registering endoing: \(endpoint), \(err)")
                } else {
                    self.registrations.append(endpoint)
                }
        }
    }
    
    func _call(action: String, args: [AnyObject], fn: (([AnyObject]) throws -> ())?) {
        let endpoint = makeEndpoint(action)
        Riffle.debug("\(domain) CALL: \(endpoint)")
        var serialized: [AnyObject]?
        
        do {
            serialized = try serialize(args)
        } catch {
            Riffle.panic("Unable to serialize arguments!")
            return
        }
        
        connection.session!.call(endpoint, payload: serialized) { (result: MDWampResult!, err: NSError!) -> Void in
            if err != nil {
                Riffle.warn("Call Error for endpoint \(endpoint): [\(err.localizedDescription)]")
            }
            else {
                if let h = fn {
                    do {
                        //Riffle.debug("Arguments for call: \(result.arguments.count)")
                        try h(result.arguments == nil ? [] : result.arguments)
                    } catch CuminError.InvalidTypes(let expected, let recieved) {
                        Riffle.warn(": cumin unable to convert: expected \(expected) but received \"\(recieved)\"[\(recieved.dynamicType)] for function \(fn) subscribed at endpoint \(endpoint)")
                    } catch {
                        Riffle.panic(" Unknown exception!")
                    }
                    
                }
            }
        }
    }
    
    public func publish(action: String, _ args: AnyObject...) {
        let endpoint = makeEndpoint(action)
        var serialized: [AnyObject]?
        
        Riffle.debug("\(domain) PUB: \(endpoint)")
        
        do {
            serialized = try serialize(args)
        } catch {
            Riffle.panic("Unable to serialize arguments!")
            return
        }
        
        connection.session!.publishTo(endpoint, args: serialized, kw: [:], options: [:]) { (err: NSError!) -> Void in
            if let e = err {
                print("Error: ", e)
                print("Publish Error for endpoint \"\(endpoint)\": \(e)")
            }
        }
    }
    
    public func unregister(action: String) {
        let endpoint = makeEndpoint(action)
        Riffle.debug("\(domain) UNREG: \(endpoint)")
        
        connection.session!.unregisterRPC(endpoint) { (err: NSError!) -> Void in
            if err != nil {
                print("Error unregistering endoint: \(endpoint), \(err)")
            } else {
                self.registrations.removeObject(endpoint)
            }
        }
    }
    
    public func unsubscribe(action: String) {
        let endpoint = makeEndpoint(action)
        Riffle.debug("\(domain) UNSUB: \(endpoint)")
        
        connection.session!.unsubscribe(endpoint) { (err: NSError!) -> Void in
            if err != nil {
                print("Error unsubscribing endoint: \(endpoint), \(err)")
            } else {
                self.subscriptions.removeObject(endpoint)
            }
        }
    }
    
    
    // MARK: Delegate Calls
    public func onJoin() {
        Riffle.debug("Agent Default onJoin")
    }
    
    public func onLeave() {
        Riffle.debug("Agent Default onLeave")
    }
    
    
    // MARK: Utilities
    func makeEndpoint(action: String) -> String {
        if action.containsString("xs.") {
            return action
        }
        
        return domain + "/" + action
    }
}
//
//  Agent.swift
//  Pods
//
//  Created by Mickey Barboi on 11/7/15.
//
//

// Recorded from the box: xs.demo.exis.biddle.Osxcontainer.gamelogic
// From live:             xs.demo.exis.biddle.Osxcontainer.gamelogic

import Foundation

public class RiffleDomain: NSObject, RiffleDelegate {
    public var name: String?
    public var domain: String
    public var delegate: RiffleDelegate?
    
    var connection: RiffleConnection
    var superdomain: RiffleDomain?
    
    var registrations: [String] = []
    var subscriptions: [String] = []
    
    
    // MARK: Initialization
    public init(domain d: String) {
        // Initialize this agent as the Application domain, or the root domain
        // for this instance of the application
        
        // Returns a domain name provided as an environment variable. If the environment variable cannot
        // be found returns the second parameter by default
        domain = env("DOMAIN", d)
        
        // If the two parameters do *not* match then we are in a container and must infer the app name
        if domain != d {
            domain = inferAppName(domain)
        }
        
        connection = RiffleConnection()
        name = domain
        
        super.init()
        delegate = self
    }
    
    public init(name n: String, superdomain s: RiffleDomain) {
        // Initialize this agent as a subdomain of the given domain. Does not
        // connect. If "connect" is called on either the superdomain or this domain
        // both will be connected
        
        // A little hacky
        if n.containsString("/") {
            domain = s.domain + n
        } else {
            domain = s.domain + "." + n
        }
        
        superdomain = s
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
    
    public func join(token: String? = nil) -> RiffleDomain {
        // Connect this agent and any agents connected to this one
        // superdomains and subdomains
        
        // Set this domain manually
        self.domain = env("DOMAIN", self.domain)
        
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
    func _subscribe(action: String, fn: ([AnyObject]) throws -> ()) -> Deferred {
        let d = Deferred()
        
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
                print("Error subscribing to endpoint \(endpoint): ", e.localizedDescription)
                d.errback()
            } else {
                self.subscriptions.append(endpoint)
                d.callback()
            }
        }
        
        return d
    }
    
    func _register(action: String, fn: ([AnyObject]) throws -> ()) -> Deferred {
        let endpoint = makeEndpoint(action)
        Riffle.debug("\(domain) REG: \(endpoint)")
        let d = Deferred()
        
        connection.session!.registerRPC(endpoint, procedure: { (wamp: MDWamp!, invocation: MDWampInvocation!) -> Void in
            Riffle.debug("INVOCATION: \(endpoint)")
            
            do {
                try fn(extractDetails(endpoint, invocation.arguments))
            } catch CuminError.InvalidTypes(let expected, let recieved) {
                Riffle.warn(": cumin unable to convert: expected \(expected) but received \"\(recieved)\"[\(recieved.dynamicType)] for function \(fn) registered at endpoint \(endpoint)")
            } catch {
                Riffle.panic(" Unknown exception!")
            }
            
            d.callback()
            wamp.resultForInvocation(invocation, arguments: [], argumentsKw: [:])
            
            }, cancelHandler: { () -> Void in
                print("Register Cancelled!")
            })
        { (err: NSError!) -> Void in
            if err != nil {
                print("Error registering endoint: \(endpoint), \(err)")
                d.errback()
            } else {
                self.registrations.append(endpoint)
            }
        }
        
        return d
    }
    
    func _register<R>(action: String, fn: ([AnyObject]) throws -> (R)) -> Deferred {
        let d = Deferred()
        let endpoint = makeEndpoint(action)
        Riffle.debug("\(domain) REG: \(endpoint)")
        
        connection.session!.registerRPC(endpoint, procedure: { (wamp: MDWamp!, invocation: MDWampInvocation!) -> Void in
            var result: R?
            Riffle.debug("INVOCATION: \(endpoint)")
            
            do {
                result = try fn(extractDetails(endpoint, invocation.arguments))
                
                // Wait for deferreds to resolve before moving forward
                if let wait = result as? Deferred {
                    wait.addCallback({ (a: AnyObject?) in
                        let serialized = try! serialize(a!)
                        wamp.resultForInvocation(invocation, arguments: serialized, argumentsKw: [:])
                        return nil
                    })
                } else {
                    if let r = result as? AnyObject {
                        let serialized = try serialize(r)
                        wamp.resultForInvocation(invocation, arguments: serialized, argumentsKw: [:])
                    }
                }
            } catch CuminError.InvalidTypes(let expected, let recieved) {
                Riffle.warn(": cumin unable to convert: expected \(expected) but received \"\(recieved)\"[\(recieved.dynamicType)] for function \(fn) registered at endpoint \(endpoint)")
                result = nil
            } catch {
                Riffle.panic(" Unknown exception!")
            }
            
            d.callback()

            }, cancelHandler: { () -> Void in
                print("Register Cancelled!")
            })
        { (err: NSError!) -> Void in
            if err != nil {
                print("Error registering endoing: \(endpoint), \(err)")
                 d.errback()
            } else {
                self.registrations.append(endpoint)
            }
        }
        
        return d
    }
    
    func _call(action: String, args: [AnyObject], fn: (([AnyObject]) throws -> ())?) -> Deferred {
        let d = Deferred()
        let endpoint = makeEndpoint(action)
        Riffle.debug("\(domain) CALL: \(endpoint)")
        var serialized: [AnyObject]?
        
        do {
            serialized = try serialize(args)
        } catch {
            Riffle.panic("Unable to serialize arguments!")
            return d
        }
        
        connection.session!.call(endpoint, payload: serialized) { (result: MDWampResult!, err: NSError!) -> Void in
            if err != nil {
                Riffle.warn("Call Error for endpoint \(endpoint): [\(err.localizedDescription)]")
                d.errback()
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
                
                d.callback()
            }
        }
        
        return d
    }
    
    public func publish(action: String, _ args: AnyObject...) -> Deferred {
        let d = Deferred()
        let endpoint = makeEndpoint(action)
        var serialized: [AnyObject]?
        
        Riffle.debug("\(domain) PUB: \(endpoint)")
        
        do {
            serialized = try serialize(args)
        } catch {
            Riffle.panic("Unable to serialize arguments!")
            return d
        }
        
        connection.session!.publishTo(endpoint, args: serialized, kw: [:], options: [:]) { (err: NSError!) -> Void in
            if let e = err {
                print("Error: ", e)
                print("Publish Error for endpoint \"\(endpoint)\": \(e)")
                d.errback()
                return
            }
            
            d.callback()
        }
        
        return d
    }
    
    public func unregister(action: String) -> Deferred {
        let d = Deferred()
        let endpoint = makeEndpoint(action)
        Riffle.debug("\(domain) UNREG: \(endpoint)")
        
        connection.session!.unregisterRPC(endpoint) { (err: NSError!) -> Void in
            if err != nil {
                print("Error unregistering endoint: \(endpoint), \(err)")
                d.errback()
            } else {
                self.registrations.removeObject(endpoint)
                d.callback()
            }
        }
        
        return d
    }
    
    public func unsubscribe(action: String) -> Deferred {
        let d = Deferred()
        let endpoint = makeEndpoint(action)
        Riffle.debug("\(domain) UNSUB: \(endpoint)")
        
        connection.session!.unsubscribe(endpoint) { (err: NSError!) -> Void in
            if err != nil {
                print("Error unsubscribing endoint: \(endpoint), \(err)")
                d.errback()
            } else {
                self.subscriptions.removeObject(endpoint)
                d.callback()
            }
        }
        
        return d
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



// Called in the case where we are *certainly* running in a container-- have to infer the app
// name as well as the container name
func inferAppName(domain: String) -> String {
    var ret = ""
    let b = domain.componentsSeparatedByString(".")
    
    for s in b[0..<(b.count - 2)] {
        ret += "\(s)."
    }
    
    return ret.substringToIndex(ret.endIndex.predecessor())
}

func extractDetails(endpoint: String, _ args: [AnyObject]) -> [AnyObject] {
    if !endpoint.containsString("#details") {
        return args
    }
    
    var ret = args
    
    if args.count > 0 {
        if let dict = args[0] as? [String: AnyObject] {
            if let element = dict["caller"] as? String {
                ret[0] = element
            }
        }
    }
    
    return ret
}


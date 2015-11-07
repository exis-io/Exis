//
//  Riffle.swift
//  Pods
//
//  Created by Mickey Barboi on 9/25/15.
//
//

import Foundation

var NODE = "wss://node.exis.io:8000/wss"
var NOPERM = false

public let rifflog = RiffleLogger()

// Sets itself as the delegate if none provided
@objc public protocol RiffleDelegate {
    func onJoin()
    func onLeave()
}


// Seting URL-- Better to use a singleton.
public func setFabric(url: String) {
    NODE = url
}


public func setDevMode(node: String = "ws://ubuntu@ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws") {
    NODE = node
    NOPERM = false
}


// Base connection for all agents connecting to a fabric
class RiffleConnection: NSObject, MDWampClientDelegate {
    var agents: [RiffleAgent] = []
    
    var open = false
    var opening = false
    
    var socket: MDWampTransportWebSocket?
    var session: MDWamp?
    
    
    func mdwamp(wamp: MDWamp!, sessionEstablished info: [NSObject : AnyObject]!) {
        rifflog.debug("Connection has been opened")
        if !open { _ = agents.map { $0.delegate?.onJoin() } }
        open = true
        opening = false
    }
    
    func mdwamp(wamp: MDWamp!, closedSession code: Int, reason: String!, details: [NSObject : AnyObject]!) {
        rifflog.debug("Connection has been closed")
        if open { _ = agents.map { $0.delegate?.onLeave() } }
        open = false
        opening = false
    }
    
    func addAgent(agent: RiffleAgent) {
        
        if agents.contains(agent) {
            print("Agent \(agent.domain) is already connected.")
        } else {
            agents.append(agent)
        }
        
        if open {
            agent.delegate?.onJoin()
        }
    }
    
    func connect(agent: RiffleAgent, token: String?) {
        
        if !open && !opening {
            socket = MDWampTransportWebSocket(server:NSURL(string: NODE), protocolVersions:[kMDWampProtocolWamp2msgpack, kMDWampProtocolWamp2json])
            session = MDWamp(transport: socket, realm: agent.domain, delegate: self)
            opening = true
            
            let connect = { (t: String) in
                self.session!.token = t
                rifflog.debug("Opening new session.")
                self.session!.connect()
            }
            
            if NOPERM {
                rifflog.debug("Opening new session.")
                self.session!.connect()
                return
            }
            
            if let t = token {
                connect(t)
            } else {
                attemptAuth(agent.name!, superdomain: agent.superdomain!.domain, completed: { (token) -> () in
                    connect(token)
                })
            }
            
        } else {
            print("Cant connection. Connection open: \(open), opening: \(opening)")
        }
    }
    
    func attemptAuth(domain: String, superdomain: String, completed: (token: String) -> ()) {
        // Login, register, login, fail
        login(domain, requesting: superdomain, success: { (token: String) -> () in
            rifflog.debug("Auth 0 completed")
            completed(token: token)
            }) { () -> () in
                register(domain, requesting: superdomain, success: { () in
                    rifflog.debug("Registration completed")
                    login(domain, requesting: superdomain, success: { (token: String) -> () in
                        rifflog.debug("Auth 0 completed")
                        completed(token: token)
                        }) { () -> () in
                            print("WARN: Domain \(domain) registered, but unable to login.")
                    }
                    
                    }, fail: { () in
                        print("WARN: Unable to register domain \(domain) as subdomain of \(superdomain)")
                })
        }
        
        // Else attempt to register
        // Return the token for node auth
    }
    
    func removeAgent(agent: RiffleAgent) {
        if !agents.contains(agent) {
            print("Agent \(agent.domain) is not connected.")
            return
        }
        
        // remove agent from array
    }
}

public class RiffleAgent: NSObject, RiffleDelegate {
    public var domain: String
    public var delegate: RiffleDelegate?
    
    var connection: RiffleConnection
    var superdomain: RiffleAgent?
    var name: String?
    
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
        rifflog.debug("\(domain) going down")
        //self.leave()
    }
    
    public func join(token: String? = nil) -> RiffleAgent {
        // Connect this agent and any agents connected to this one
        // superdomains and subdomains
        
        unowned let weakSelf = self
        connection.addAgent(weakSelf)
        
        if superdomain != nil && superdomain!.connection.open {
            superdomain!.join(token)
        } else {
            connection.connect(weakSelf, token: token)
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
        rifflog.debug("\(domain) SUB: \(endpoint)")
        
        connection.session!.subscribe(endpoint, onEvent: { (event: MDWampEvent!) -> Void in
            do {
                try fn(event.arguments)
            } catch CuminError.InvalidTypes(let expected, let recieved) {
                rifflog.warn(": cumin unable to convert: expected \(expected) but received \"\(recieved)\"[\(recieved.dynamicType)] for function \(fn) subscribed at endpoint \(endpoint)")
            } catch {
                rifflog.panic(" Unknown exception!")
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
        rifflog.debug("\(domain) REG: \(endpoint)")
        
        connection.session!.registerRPC(endpoint, procedure: { (wamp: MDWamp!, invocation: MDWampInvocation!) -> Void in
            
            rifflog.debug("INVOCATION: \(endpoint)")
            
            do {
                try fn(invocation.arguments)
            } catch CuminError.InvalidTypes(let expected, let recieved) {
                rifflog.warn(": cumin unable to convert: expected \(expected) but received \"\(recieved)\"[\(recieved.dynamicType)] for function \(fn) registered at endpoint \(endpoint)")
            } catch {
                rifflog.panic(" Unknown exception!")
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
        rifflog.debug("\(domain) REG: \(endpoint)")
        
        connection.session!.registerRPC(endpoint, procedure: { (wamp: MDWamp!, invocation: MDWampInvocation!) -> Void in
            var result: R?
            
            rifflog.debug("INVOCATION: \(endpoint)")
            
            do {
                result = try fn(invocation.arguments)
            } catch CuminError.InvalidTypes(let expected, let recieved) {
                rifflog.warn(": cumin unable to convert: expected \(expected) but received \"\(recieved)\"[\(recieved.dynamicType)] for function \(fn) registered at endpoint \(endpoint)")
                result = nil
            } catch {
                rifflog.panic(" Unknown exception!")
            }
            
            if let autoArray = result as? [AnyObject] {
                wamp.resultForInvocation(invocation, arguments: serialize(autoArray), argumentsKw: [:])
            } else {
                wamp.resultForInvocation(invocation, arguments: serialize([result as! AnyObject]), argumentsKw: [:])
            }
            
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
        rifflog.debug("\(domain) CALL: \(endpoint)")
        
        connection.session!.call(endpoint, payload: serialize(args)) { (result: MDWampResult!, err: NSError!) -> Void in
            if err != nil {
                print("Call Error for endpoint \(endpoint): \(err)")
            }
            else {
                if let h = fn {
                    do {
                        //rifflog.debug("Arguments for call: \(result.arguments.count)")
                        try h(result.arguments == nil ? [] : result.arguments)
                    } catch CuminError.InvalidTypes(let expected, let recieved) {
                        rifflog.warn(": cumin unable to convert: expected \(expected) but received \"\(recieved)\"[\(recieved.dynamicType)] for function \(fn) subscribed at endpoint \(endpoint)")
                    } catch {
                        rifflog.panic(" Unknown exception!")
                    }
                    
                }
            }
        }
    }
    
    public func publish(action: String, _ args: AnyObject...) {
        let endpoint = makeEndpoint(action)
        rifflog.debug("\(domain) PUB: \(endpoint)")
        
        connection.session!.publishTo(endpoint, args: serialize(args), kw: [:], options: [:]) { (err: NSError!) -> Void in
            if let e = err {
                print("Error: ", e)
                print("Publish Error for endpoint \"\(endpoint)\": \(e)")
            }
        }
    }
    
    public func unregister(action: String) {
        let endpoint = makeEndpoint(action)
        rifflog.debug("\(domain) UNREG: \(endpoint)")
        
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
        rifflog.debug("\(domain) UNSUB: \(endpoint)")
        
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
        rifflog.debug("Agent Default onJoin")
    }
    
    public func onLeave() {
        rifflog.debug("Agent Default onLeave")
    }
    
    
    // MARK: Utilities
    func makeEndpoint(action: String) -> String {
        if action.containsString("xs.") {
            return action
        }
        
        return domain + "/" + action
    }
}


extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

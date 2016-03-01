//
//  Connection.swift
//  Pods
//
//  Created by Mickey Barboi on 11/7/15.
//
//

import Foundation

// Base connection for all agents connecting to a fabric
class RiffleConnection: NSObject, MDWampClientDelegate {
    var agents: [RiffleDomain] = []
    
    var open = false
    var opening = false
    
    var socket: MDWampTransportWebSocket?
    var session: MDWamp?
    
    
    func mdwamp(wamp: MDWamp!, sessionEstablished info: [NSObject : AnyObject]!) {
        Riffle.debug("Connection has been opened")
        if !open { _ = agents.map { $0.delegate?.onJoin() } }
        open = true
        opening = false
    }
    
    func mdwamp(wamp: MDWamp!, closedSession code: Int, reason: String!, details: [NSObject : AnyObject]!) {
        Riffle.debug("Connection has been closed")
        if open { _ = agents.map { $0.delegate?.onLeave() } }
        open = false
        opening = false
    }
    
    func addAgent(agent: RiffleDomain) {
        
        if !agents.contains(agent) {
            agents.append(agent)
        }
        
        if open {
            agent.delegate?.onJoin()
        }
    }
    
    func connect(agent: RiffleDomain, token: String?) {
        
        if !open && !opening {
            socket = MDWampTransportWebSocket(server:NSURL(string: NODE), protocolVersions:[kMDWampProtocolWamp2msgpack, kMDWampProtocolWamp2json])
            session = MDWamp(transport: socket, realm: agent.domain, delegate: self)
            opening = true
            
            if SOFTNODE {
                self.session!.connect()
                return
            }
            
            let envToken = env("EXIS_TOKEN", "")
            
            if envToken != "" {
                Riffle.debug("Found variable from environment: \(envToken)")
                self.session!.token = envToken
                self.session!.connect()
            } else if let t = token {
                Riffle.debug("Using local token: \(t)")
                self.session!.token = t
                self.session!.connect()
            } else {
                Riffle.debug("No token found. Attempting Auth-0")
                attemptAuth(agent.name!, superdomain: agent.superdomain!.domain, completed: { (t) -> () in
                    self.session!.token = t
                    self.session!.connect()
                })
            }
            
        } else {
            print("Cant connection. Connection open: \(open), opening: \(opening)")
        }
    }
    
    func attemptAuth(domain: String, superdomain: String, completed: (token: String) -> ()) {
        // Login, register, login, fail
        login(domain, requesting: superdomain, success: { (token: String) -> () in
            Riffle.debug("Auth 0 completed")
            completed(token: token)
        }) { () -> () in
            register(domain, requesting: superdomain, success: { () in
                Riffle.debug("Registration completed")
                login(domain, requesting: superdomain, success: { (token: String) -> () in
                    Riffle.debug("Auth 0 completed")
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
    
    func removeAgent(agent: RiffleDomain) {
        if !agents.contains(agent) {
            print("Agent \(agent.domain) is not connected.")
            return
        }
        
        // remove agent from array
    }
}
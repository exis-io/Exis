//
//  main.swift
//  Backend
//
//  Created by Damouse on 11/7/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation
import Riffle

let app = RiffleDomain(domain: "xs.demo.damouse.test")
let token = "HWDBNNyy54IZAY67eU8N.-rzEF2qitlxmM-JolSfdk.tTPR6CDlSgRR8K.9d6iii-VXf7xbHj1ebSotySI5a-7DfiKcsLcMUpiwO9Bq.EA4-Uu-lw9aAzpDy2ellXzLNkdQl6TTulLVsvR-WJ9RHbirpIkF2SAmiEZmey8vCtXo_"

// How long each round takes, in seconds
let ANSWER_TIME = 10.0
let PICK_TIME = 8.0
let SCORE_TIME = 5.0
let EMPTY_TIME = 1.0


class Container: RiffleDomain {
    var rooms: [Room] = []
    
    
    override func onJoin() {
        print("Container joined as \(domain)")
        app.subscribe("sessionLeft", playerLeft)
        register("play#details", play)
        
        // Create a dynamic role to give to players later
        app.call("xs.demo.Bouncer/addDynamicRole", "player", self.domain, [
            ["target": "\(domain)/$/pick", "verb":"c"],
            ["target": "\(domain)/$/leave", "verb":"c"],
            ["target": "\(domain)/$/answering", "verb":"s"],
            ["target": "\(domain)/$/picking", "verb":"s"],
            ["target": "\(domain)/$/scoring", "verb":"s"],
            ["target": "\(domain)/$/left", "verb":"s"],
            ["target": "\(domain)/$/joined", "verb":"s"]
        ], handler: nil)
    }
    
    
    func play(player: String) -> AnyObject {
        var emptyRooms = rooms.filter { $0.players.count < 6 }
        if emptyRooms.count == 0 {
            let d = Deferred()
            
            app.call("xs.demo.Bouncer/newDynamicRole", "player", self.domain, handler: { (res: String) in
                let room = Room(name: "/" + res, superdomain: self)
                room.dynamicRoleId = res
                self.rooms.append(room)
                d.callback(room.addPlayer(player as String))
            })
            
            return d
        } else {
            let room = emptyRooms.randomElements(1)[0]
            return room.addPlayer(player as String)
        }
    }
    
    func playerLeft(domain: String) {
        for room in rooms {
            if let _ = getPlayer(room.players, domain: domain) {
                room.removePlayer(domain)
                return
            }
        }
    }
}

let container = Container(name: "Osxcontainer.gamelogic", superdomain: app)
container.join(token)
NSRunLoop.currentRunLoop().run()


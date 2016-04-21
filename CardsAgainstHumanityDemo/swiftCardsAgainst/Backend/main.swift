//
//  main.swift
//  Backend
//
//  Created by Damouse on 11/7/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation
import Riffle

// Testing locally 
Riffle.setFabricDev()
Riffle.setLogLevelDebug()

let app = Domain(name: "xs.demo.exis.cardsagainst")

// How long each round takes, in seconds
let ANSWER_TIME = 10.0
let PICK_TIME = 8.0
let SCORE_TIME = 5.0
let EMPTY_TIME = 1.0


class Container: Domain {
    var rooms: [Room] = []
    
    
    override func onJoin() {
        print("Container joined as \(name)")
        app.subscribe("sessionLeft", playerLeft)
        register("play", options: Options(details: true), play)
        
        // Create a dynamic role to give to players later
//        app.call("xs.demo.Bouncer/addDynamicRole", "player", name, [
//            ["target": "\(name)/$/pick", "verb":"c"],
//            ["target": "\(name)/$/leave", "verb":"c"],
//            ["target": "\(name)/$/answering", "verb":"s"],
//            ["target": "\(name)/$/picking", "verb":"s"],
//            ["target": "\(name)/$/scoring", "verb":"s"],
//            ["target": "\(name)/$/left", "verb":"s"],
//            ["target": "\(name)/$/joined", "verb":"s"]
//        ])
    }
    
    
    func play(player: String) -> ([String], [Player], String, String) {
        var emptyRooms = rooms.filter { $0.players.count < 6 }
        if emptyRooms.count == 0 {
            let room = Room(name: randomStringWithLength(6), superdomain: self)
            self.rooms.append(room)
            return room.addPlayer(player)
            
//            let d = Deferred()
//            
//            app.call("xs.demo.Bouncer/newDynamicRole", "player", name).then { (res: String) in
//                let room = Room(name: "/" + res, superdomain: self)
//                room.dynamicRoleId = res
//                self.rooms.append(room)
//                d.callback(room.addPlayer(player))
//            }
//            
//            return d
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
container.join()
NSRunLoop.currentRunLoop().run()


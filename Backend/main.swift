//
//  main.swift
//  Backend
//
//  Created by Damouse on 11/7/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation
import Riffle

print("Container Starting")


// How long each round takes, in seconds
let ANSWER_TIME = 5.0
let PICK_TIME = 5.0
let SCORE_TIME = 3.0
let EMPTY_TIME = 1.0

let token = "tyXIUowkckzbDWLm6MlT8wngluL4SUUM+uexMCPiIASJuGhJPz6rAc/BEfm/+zV6Y5jbOs+ca+PD3iTFKphPzvoJyrFzewU0ZAriVGBcYsO+w7z7uBw9EJYWv/o2BDqsXgRwqcgBj1RrVqrBwIBZvRxEax0kgZe7drKPjloMEQ0="

//Riffle.setDevFabric()
let app = RiffleDomain(domain: "xs.demo.damouse.cardsagainst")



class Container: RiffleDomain {
    var rooms: [Room] = []
    var questions = loadCards("q13")
    var answers = loadCards("a13")
    
    
    override func onJoin() {
        print("Container joined")
        app.subscribe("sessionLeft", playerLeft)
        register("play", play)
    }
    
    
    func play(player: String) -> AnyObject {
        var emptyRooms = rooms.filter { $0.players.count < 6 }
        var room: Room
        
        if emptyRooms.count == 0 {
            room = Room(name: "room" + randomStringWithLength(6), superdomain: self)
            room.parent = self
            room.questions = questions
            room.answers = answers
            rooms.append(room)
        } else {
            room = emptyRooms.randomElements(1)[0]
        }
        
        return room.addPlayer(player as String)
    }
    
    func closeRoom(room: Room) {
        print("Closing room.")
        rooms.removeObject(room)
    }
    
    func playerLeft(domain: String) {
        for room in rooms {
            for player in room.players {
                if player.domain == domain {
                    room.removePlayer(player)
                    return
                }
            }
        }
    }
}

Container(name: "container", superdomain: app).join(token)
NSRunLoop.currentRunLoop().run()


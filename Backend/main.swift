//
//  main.swift
//  Backend
//
//  Created by Damouse on 11/7/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation
import Riffle


// This is used for testing the container locally.
let token = "2ftG4nLny2qfM-9apHuECRr8U3gPJj9ZtaMuW928p-eYzvCoxx7ChvP.HwITsCbo3l0XzY528FS2lMBIQOYlAx70nWvUL9F36HK0HA.maI5xJ1Gz1PMQA993jQfkcnhIJJhHn0QXJAnIiaSDmiTgJ2BqAVmtJK5icL7qW0SHjMo_"


// How long each round takes, in seconds
let ANSWER_TIME = 5.0
let PICK_TIME = 5.0
let SCORE_TIME = 3.0
let EMPTY_TIME = 1.0


let app = RiffleDomain(domain: "xs.demo.damouse.cardsagainst")
//Riffle.setDebug()


class Container: RiffleDomain {
    var rooms: [Room] = []
    var questions = loadCards("q13")
    var answers = loadCards("a13")
    
    
    override func onJoin() {
        print("Container joined")
        app.subscribe("sessionLeft", playerLeft)
        register("play", play)
        
        // Set up a dynamic role for this container
        let permissions = [
            ["target": self.domain + "/$/pick", "verb":"c"],
            ["target": self.domain + "/$/leave", "verb":"c"],
            ["target": self.domain + "/$/answering", "verb":"s"],
            ["target": self.domain + "/$/picking", "verb":"s"],
            ["target": self.domain + "/$/scoring", "verb":"s"]
        ]
        
        app.call("xs.demo.Bouncer/addDynamicRole", "player", self.domain, permissions, handler: nil)
        
        // Create one room
        app.call("xs.demo.Bouncer/newDynamicRole", "player", self.domain, handler: { (res: String) in
            let room = Room(name: "/" + res, superdomain: self)
            room.parent = self
            room.dynamicRoleId = res
            room.questions = self.questions
            room.answers = self.answers
            self.rooms.append(room)
        })
    }
    
    
    func play(player: String) -> AnyObject {
        var emptyRooms = rooms.filter { $0.players.count < 6 }
        var room: Room
        
        if emptyRooms.count == 0 {
            print("WARN: no empty rooms found. Unable to allocate space for player!")
            room = emptyRooms.randomElements(1)[0]
        } else {
            room = emptyRooms.randomElements(1)[0]
        }
        
        return room.addPlayer(player as String)
    }
    
    func closeRoom(room: Room) {
        print("Closing room.")
        //rooms.removeObject(room)
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

Container(name: "Osxcontainer.gamelogic", superdomain: app).join(token)
NSRunLoop.currentRunLoop().run()


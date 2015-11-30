//
//  Room.swift
//  ExAgainst
//
//  Created by Mickey Barboi on 11/19/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation
import Riffle

class Room: RiffleDomain {
    var parent: Container!
    var timer: DelayedCaller!
    
    var dynamicRoleId: String!
    var state: String = "Empty"
    
    var players: [Player] = []
    var czar: Player?
    var questions: [String]!
    var answers: [String]!
    
    
    override func onJoin() {
        timer = DelayedCaller(target: self)
        
        register("pick", pick)
        register("leave", removePlayer)
    }
    
    func removePlayer(domain: String) {
        let player = players.filter { $0.domain == domain }[0]
        print("Removing player: \(player.domain)")
        answers.appendContentsOf(player.hand)
        
        if let p = player.pick {
            answers.append(p)
        }
        
        players.removeObject(player)
        publish("left", player)
        
        // What happens if the current player is a czar?
        // Either zombie or reset play
        
        // remove the role from the player that left, ensuring they can't call our endpoints anymore
        app.call("xs.demo.Bouncer/revokeDynamicRole", self.dynamicRoleId, "player", parent.domain, [player.domain], handler: nil)
        
        // Close the room if there are only demo players left
//        if players.reduce(0, combine: { $0 + ($1.demo ? 0 : 1) }) == 0 {
//            parent.closeRoom(self)
//            parent = nil
//            timer.cancel()
//        }
    }
    
    func addPlayer(domain: String) -> AnyObject {
        // Add the new player and draw them a hand. Let everyone else in the room know theres a new player
        print("Adding Player \(domain)")
        
        let newPlayer = Player()
        newPlayer.domain = domain
        newPlayer.demo = false
        newPlayer.hand = answers.randomElements(4, remove: true)
        
        players.append(newPlayer)
        
        // Add dynamic role
        app.call("xs.demo.Bouncer/assignDynamicRole", self.dynamicRoleId, "player", parent.domain, [domain], handler: nil)
        
        // Add Demo players
        if players.count < 3 {
            for i in 0...2 {
                let player = Player()
                player.domain = app.domain + ".demo\(i)"
                player.hand = answers.randomElements(10, remove: true)
                player.demo = true
                players.append(player)
            }
        }
        
        timer.startTimer(EMPTY_TIME, selector: "startAnswering")
        
        return [newPlayer.hand, players, state, self.name!]
    }
    
    func pick(player: Player, card: String) {
        // Player picked a card. This action depends on the current state of play
        
        let player = players.filter { $0.domain == player.domain }[0]
        
        if state == "Answering" && player.pick == nil && !player.czar {
            player.pick = card
            player.hand.removeObject(card)
            print("Player: \(player.domain) answered: \(card)")
            
        } else if state == "Picking" && player.czar {
            print("Ending Choosing early")
            let winner = players.filter { $0.pick == card }[0]
            timer.startTimer(0.0, selector: "startScoring:", info: winner.domain)
            
        } else {
            print("Player pick in wrong round!")
        }
    }
    
    func startAnswering() {
        print("    Answering -- ")
        state = "Answering"
        
        setNextCzar()
        publish("answering", czar!, questions.randomElements(1, remove: false)[0], PICK_TIME)
        timer.startTimer(PICK_TIME, selector: "startPicking")
    }
    
    func startPicking() {
        print("    Picking -- ")
        state = "Picking"
        
        let pickers = players.filter { !$0.czar }
        
        // Autopick for players that didnt pick
        for player in pickers {
            if player.pick == nil {
                player.pick = player.hand.randomElements(1, remove: true)[0]
            }
        }
        
        publish("picking", pickers.map({ $0.pick! }), PICK_TIME)
        
        timer.startTimer(PICK_TIME, selector: "startScoring:")
    }
    
    func startScoring(t: NSTimer) {
        print("    Scoring -- ")
        state = "Scoring"
        
        var pickers = players.filter { !$0.czar }
        var winner: Player?
        
        if let domain = t.userInfo as? String {
            winner = players.filter { $0.domain == domain }[0]
        } else {
            print("No players picked cards! Choosing one at random")
            winner = pickers.randomElements(1, remove: false)[0]
        }
        
        winner!.score += 1
        publish("scoring", winner!, winner!.pick!, SCORE_TIME)
        
        // draw cards for all players, nil their picks
        for p in pickers {
            if let c = p.pick {
                answers.append(c)
                p.hand.removeObject(c)
            }
            
            let newAnswer = answers.randomElements(1, remove: true)
            p.hand += newAnswer
            p.pick = nil
            
            // If this isn't a demo player deal them a new card
            if !p.demo {
                call(p.domain + "/draw", newAnswer, handler: nil)
            }
        }
        
        timer.startTimer(SCORE_TIME, selector: "startAnswering")
    }
    
    func setNextCzar() {
        if czar == nil {
            czar = players[0]
            czar!.czar = true
        } else {
            let i = players.indexOf(czar!)!
            let newCzar = players[(i + 1) % (players.count - 1)]
            czar!.czar = false
            newCzar.czar = true
            czar = newCzar
        }
        
        print("New Czar: \(czar!.domain)")
    }
}
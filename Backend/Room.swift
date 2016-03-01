//
//  Room.swift
//  ExAgainst
//
//  Created by Mickey Barboi on 11/19/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation
import Riffle

var baseQuestions = loadCards("q13")
var baseAnswers = loadCards("a13")


class Room: RiffleDomain {
    var timer: DelayedCaller!
    var dynamicRoleId: String!
    var state: String = "Empty"
    
    var players: [Player] = []
    var czar: Player?
    var questions = baseQuestions
    var answers = baseAnswers
    
    
    override func onJoin() {
        timer = DelayedCaller(target: self)
        register("pick#details", pick)
        register("leave#details", removePlayer)
    }
    
    func removePlayer(domain: String) {
        if let player = getPlayer(players, domain: domain) {
            print("Player marked as zombie: \(domain)")
            player.zombie = true
            player.demo = true
        } else {
            print("WARN-- asked to remove player \(domain), not found in players!")
        }
    }
    
    func addPlayer(domain: String) -> AnyObject {
        // Add the new player and draw them a hand. Let everyone else in the room know theres a new player
        print("Adding Player \(domain)")
        
        // When the player leaves they're marked as a zombie. All zombies are cleared out at the end of a round, 
        // but if a player leaves and then rejoins before their zombie was cleared out then we'll have two players with the same name
        // If the player's name already exists in the app, unzombiefy them instead of creating a new player
        if let existingPlayer = getPlayer(players, domain: domain) {
            existingPlayer.zombie = false
            existingPlayer.demo = false
            return [existingPlayer.hand, players, state, self.name!]
        }
        
        let newPlayer = Player()
        newPlayer.domain = domain
        newPlayer.demo = false
        newPlayer.hand = answers.randomElements(4, remove: true)
        
        players.append(newPlayer)
        publish("joined", newPlayer)

        // Add dynamic role
        app.call("xs.demo.Bouncer/assignDynamicRole", self.dynamicRoleId, "player", container.domain, [domain], handler: nil)
        
        if state == "Empty" {
            timer.startTimer(EMPTY_TIME, selector: "startAnswering")
            roomMaintenance()
        }
        
        return [newPlayer.hand, players, state, self.name!]
    }
    
    func pick(domain: String, card: String) {
        guard let player = getPlayer(players, domain: domain) else { return }
        
        if state == "Answering" && player.pick == nil && !player.czar {
            guard let pick = player.hand.removeObject(card) else { return }
            player.pick = pick
            print("Player: \(player.domain) answered: \(card)")
            
        } else if state == "Picking" && player.czar {
            let winner = players.filter { $0.pick == card }[0]
            timer.startTimer(0.0, selector: "startScoring:", info: winner.domain)
        }
    }
    
    
    // MARK: Round Transitions
    func startAnswering() {
        // Close the room if there are only demo players left
        if players.reduce(0, combine: { $0 + ($1.demo ? 0 : 1) }) == 0 {
            container.rooms.removeObject(self)
            players = []
            timer.cancel()
            return
        }
        
        print("    Answering -- ")
        state = "Answering"
        roomMaintenance()

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
        
        // Choose a winner at random if the czar didn't choose one
        var pickers = players.filter { !$0.czar }
        var winner = pickers.randomElements(1, remove: false)[0]
        
        if let domain = t.userInfo as? String {
            if let p = getPlayer(players, domain: domain) {
                winner = p
            }
        }
        
        winner.score += 1
        publish("scoring", winner, winner.pick!, SCORE_TIME)
        
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
    
    
    // MARK: Player Utils
    func roomMaintenance() {
        // Players that left in the middle of a round of play are only removed once, at the start of a new round
        // in order to avoid round restarts or interrupted play
        for player in players.filter({ $0.zombie }) {
            print("Removing zombies: \(player.domain)")
            answers.appendContentsOf(player.hand)
            
            if let p = player.pick {
                answers.append(p)
            }
            
            players.removeObject(player)
            publish("left", player)
            czar = player.czar ? nil : czar
            
            // remove the role from the player that left, ensuring they can't call our endpoints anymore
            app.call("xs.demo.Bouncer/revokeDynamicRole", self.dynamicRoleId, "player", container.domain, [player.domain], handler: nil)
        }
        
        // If there aren't enough players to play a full
        while players.count < 3 {
            let player = Player()
            player.domain = app.domain + ".demo\(randomStringWithLength(4))"
            player.hand = answers.randomElements(10, remove: true)
            player.demo = true
            players.append(player)
            
            if state != "Empty" {
                publish("joined", player)
            }
        }
        
        // Set the next czar round-robin, or randomly if no player is currently the czar
        if czar == nil {
            czar = players.randomElements(1)[0]
            czar!.czar = true
        } else {
            let i = players.indexOf(czar!)!
            let newCzar = players[(i + 1) % (players.count)]
            czar!.czar = false
            newCzar.czar = true
            czar = newCzar
        }
        
        print("New Czar: \(czar!.domain)")
    }
}
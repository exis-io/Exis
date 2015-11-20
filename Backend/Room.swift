//
//  Room.swift
//  ExAgainst
//
//  Created by Mickey Barboi on 11/19/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation
import Riffle

class Room: RiffleAgent {
    var timer: DelayedCaller!
    
    var state: String = "Empty"
    var players: [Player] = []
    var czar: Player?

    var questions: [String]!
    var answers: [String]!

    
    override func onJoin() {
        timer = DelayedCaller(target: self)
        
        register("play", addPlayer)
        register("pick", pick)
    }
    
    
    func removePlayer(player: Player) {
        print("Removing player: \(player.domain)")
        
        answers.appendContentsOf(player.hand)
        
        if let p = player.pick {
            answers.append(p)
        }
        
        players.removeObject(player)
        
        publish("left", player)
    }
    
    func addPlayer(domain: String) -> AnyObject {
        // Add the new player and draw them a hand. Let everyone else in the room know theres a new player
        
        print("Adding Player \(domain)")
        
        let newPlayer = Player()
        newPlayer.domain = domain
        newPlayer.hand = answers.randomElements(4, remove: true)
        
        players.append(newPlayer)
        
        // Add Demo players
        for i in 0...2 {
            let player = Player()
            player.domain = app.domain + ".demo\(i)"
            player.hand = answers.randomElements(10, remove: true)
            player.demo = true
            players.append(player)
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
        
        // draw cards for all players
        for p in pickers {
            if let c = p.pick {
                answers.append(c)
                p.hand.removeObject(c)
            }
            
            let newAnswer = answers.randomElements(1, remove: true)
            p.hand += newAnswer
            p.pick = nil
        }

        if let p = winner!.pick {
            publish("scoring", winner!, winner!.pick!, SCORE_TIME)
        }
        else {
            print("The winner doesn't have a listed pick!")
            publish("scoring", winner!, "BASDBASB", SCORE_TIME)
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
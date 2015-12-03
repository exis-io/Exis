//
//  Shared.swift
//  FabAgainstBackend
//
//  Created by Damouse on 10/1/15.
//  Copyright © 2015 paradrop. All rights reserved.

// This code is shared across the app and the container.

import Foundation
import Riffle


class Player: RiffleModel {
    var domain = ""
    var score = 0
    
    var hand: [String] = []
    var pick: String?
    
    var czar = false
    var demo = true
    var zombie = false
    
    override class func ignoreProperties() -> [String] {
        return ["hand", "pick", "zombie"]
    }
}


// Used to compare two players together
func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.domain == rhs.domain
}


// Given a domain, return the player that matches that domain from an array. If the player is not 
// present in the array retun nil
func getPlayer(players: [Player], domain: String) -> Player? {
    let filtered = players.filter({$0.domain == domain})
    
    if filtered.count != 1 {
        return nil
    }
    
    return filtered[0]
}


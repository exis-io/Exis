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
    var czar = false
<<<<<<< HEAD:ExAgainst/Player.swift
    var demo = false
=======
    var demo = true
>>>>>>> pretty:ExAgainst/Models.swift
    var hand: [String] = []
    var pick: String?
    
    override class func ignoreProperties() -> [String] {
        return ["hand", "pick"]
    }
}


// Used to compare two players together
func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.domain == rhs.domain
}


// Given a domain, return the player that matches that domain from an array
func getPlayer(players: [Player], domain: String) -> Player {
    return players.filter({$0.domain == domain})[0]
}


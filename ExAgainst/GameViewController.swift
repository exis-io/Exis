//
//  GameViewController.swift
//  FabAgainst
//
//  Created by Damouse on 9/29/15.
//  Copyright © 2015 paradrop. All rights reserved.
//



import UIKit
import Riffle
import RMSwipeTableViewCell
import M13ProgressSuite
import Spring

class GameViewController: UIViewController {
    
    @IBOutlet weak var viewProgress: TickingView!
    @IBOutlet weak var labelActiveCard: UILabel!
    @IBOutlet weak var tableCard: UITableView!
    @IBOutlet weak var collectionPlayers: UICollectionView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var viewRound: SpringView!
    @IBOutlet weak var labelRound: UILabel!
    
    var tableDelegate: CardTableDelegate!
    var collectionDelegate: PlayerCollectionDelegate!

    var players: [Player] = []
    var currentPlayer: Player!
    var state: String!
    
    var app: RiffleAgent!
    var room: RiffleAgent!
    var me: RiffleAgent!
    
    var players: [Player] = []
    var currentPlayer: Player!
    var state: String = "Scoring"
    
    
    override func viewDidLoad() {
        tableDelegate = CardTableDelegate(tableview: tableCard, parent: self)
        collectionDelegate = PlayerCollectionDelegate(collectionview: collectionPlayers, parent: self, baseAppName: app.domain)
        
        buttonBack.imageView?.contentMode = .ScaleAspectFit
        
        collectionDelegate.refreshPlayers(players)
        tableDelegate.refreshCards(currentPlayer.hand)
        
        room.subscribe("answering", answering)
        room.subscribe("picking", picking)
        room.subscribe("scoring", scoring)
        me.register("draw", draw)
    }
    
    override func viewWillDisappear(animated: Bool) {
        room.call("leave", currentPlayer, handler: nil)
        room.leave()
    }
    
    @IBAction func leave(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Game Logics
    func answering(newCzar: Player, question: String, time: Double) {
        print("Answering. New czar: \(newCzar.domain)")
        state = "Answering"
        
        labelActiveCard.text = question
        _ = players.map { $0.czar = $0 == newCzar }
        collectionDelegate.setCzar(newCzar)
        tableDelegate.refreshCards(newCzar.domain == me.domain ? [] : currentPlayer.hand)
        viewProgress.countdown(time)
    }
    
    func picking(answers: [String], time: Double) {
        print("Picking")
        state = "Picking"
        
        var found = false
        
        for answer in answers {
            if currentPlayer.hand.contains(answer) {
                print("Removed card: \(answer)")
                found = true
                currentPlayer.hand.removeObject(answer)
            }
        }
        
        if !found && !currentPlayer.czar {
            print("WARN-- no card removed! Hand: \(currentPlayer.hand), answers: \(answers)")
        }
        
        tableDelegate.refreshCards(answers)
        viewProgress.countdown(time)
    }
    
    func scoring(player: Player, card: String, time: Double) {
        print("Scoring. Player: \(player.domain) won")
        state = "Scoring"
        
        for p in players {
            if p == player {
                p.score += 1
            }
        }
        
        collectionDelegate.refreshPlayers(players)
        collectionDelegate.flashCell(player)
        tableDelegate.refreshCards([card])
        
        viewProgress.countdown(time)
    }
    
    func playerSwiped(card: String) {
        // Called when a player swipes a cell with the card that cell represents
        
        if tableDelegate.cards.count != 1 && (state == "Answering" || state == "Picking" && currentPlayer.czar) {
            tableDelegate.removeCellsExcept([card])
        }
        
        room.call("pick", currentPlayer, card, handler: nil)
    }
    
    func draw(cards: [String]) {
        currentPlayer.hand += cards
    }
}
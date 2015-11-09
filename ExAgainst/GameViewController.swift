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


class GameViewController: UIViewController {
    
    @IBOutlet weak var viewProgress: TickingView!
    @IBOutlet weak var labelActiveCard: UILabel!
    @IBOutlet weak var tableCard: UITableView!
    @IBOutlet weak var collectionPlayers: UICollectionView!
    @IBOutlet weak var buttonBack: UIButton!
    
    var tableDelegate: CardTableDelegate!
    var collectionDelegate: PlayerCollectionDelegate!
    
    var players: [Player] = []
    var currentPlayer: Player!
    
    var app: RiffleAgent!
    var container: RiffleAgent!
    var me: RiffleAgent!
    
    
    override func viewDidLoad() {
        tableDelegate = CardTableDelegate(tableview: tableCard, parent: self)
        collectionDelegate = PlayerCollectionDelegate(collectionview: collectionPlayers, parent: self, baseAppName: app.domain)
        
        buttonBack.imageView?.contentMode = .ScaleAspectFit
        
        collectionDelegate.refreshPlayers(players)
        tableDelegate.refreshCards(currentPlayer.hand)
        
        container.subscribe("answering", answering)
        container.subscribe("choosing", picking)
        container.subscribe("scoring", scoring)
        me.register("draw", draw)
    }
    
    override func viewWillDisappear(animated: Bool) {
        container.call("leave", currentPlayer, handler: nil)
        container.leave()
    }
    
    @IBAction func leave(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Game Logics
    func answering(newCzar: Player, question: String, time: Double) {
        print("Answering. New czar: \(newCzar.domain)")
        
        labelActiveCard.text = question
        _ = players.map { $0.czar = $0 == newCzar }
        collectionDelegate.setCzar(newCzar)
        tableDelegate.refreshCards(newCzar == me ? [] : currentPlayer.hand)
        viewProgress.countdown(time)
    }
    
    func picking(answers: [String], time: Double) {
        print("Picking")
        
        for answer in answers {
            if currentPlayer.hand.contains(answer) {
                currentPlayer.hand.removeObject(answer)
            }
        }
        
        tableDelegate.refreshCards(answers)
        viewProgress.countdown(time)
    }
    
    func scoring(player: Player, time: Double) {
        print("Scoring. Player: \(player.domain) won")
        
        for p in players {
            if p == player {
                p.score += 1
            }
        }
        
        collectionDelegate.refreshPlayers(players)
        collectionDelegate.flashCell(player)
        viewProgress.countdown(time)
    }
    
    func playerSwiped(card: String) {
        // Called when a player swipes a cell with the card that cell represents
        container.call("pick", currentPlayer, card, handler: nil)
    }
    
    func draw(cards: [String]) {
        currentPlayer.hand += cards
    }
}
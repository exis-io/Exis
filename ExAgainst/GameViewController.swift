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
    var app: RiffleAgent!
    var container: RiffleAgent!
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        container.call("leave", currentPlayer, handler: nil)
        container.leave()
    }
    
    @IBAction func leave(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Game Logics
    func playerSwiped(card: String) {
        // Called when a player swipes a cell with the card that cell represents
        container.call("pick", currentPlayer, card, handler: nil)
    }
}
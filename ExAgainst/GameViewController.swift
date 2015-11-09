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
    
    
    // These objects manage the Table and Collection views. They act as delegates and data source for each
    // in order to keep the view code seperate from the game logic.
    //
    // To update the views, call:
    //      tableDelegate.refreshCards(newCards)
    //      collectionDelegate.refreshPlayers(newPlayers)
    var tableDelegate: CardTableDelegate!
    var collectionDelegate: PlayerCollectionDelegate!
    
    
    // The current state of the game as reported by the room
    var state: String = "Empty"
    var players: [Player] = []
    var currentPlayer: Player!
    
    
    // The room domain and the current player
    var app: RiffleAgent!
    var container: RiffleAgent!
    var me: RiffleAgent!
    
    
    override func viewDidLoad() {
        // Setup the view delegates
        tableDelegate = CardTableDelegate(tableview: tableCard, parent: self)
        collectionDelegate = PlayerCollectionDelegate(collectionview: collectionPlayers, parent: self, baseAppName: app.domain)
        
        // Style the back button so it doesnt stretch
        buttonBack.imageView?.contentMode = .ScaleAspectFit
        
        // Set the collection and table with initial data
        collectionDelegate.refreshPlayers(players)
        tableDelegate.refreshCards(currentPlayer.hand)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Tell the room we're going to leave
        container.call("leave", currentPlayer, handler: nil)
        
        // Unregisters and unsubscribes to all endpoints on this domain
        container.leave()
    }
    
    @IBAction func leave(sender: AnyObject) {
        // Back button. Dismiss the current view controller and trigger leave callbacks
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    ////////////////////////////////////////////////////////////////////////////
    // Game Logic
    // These methods are called from the room and change the UI
    ////////////////////////////////////////////////////////////////////////////
    
    func playerSwiped(card: String) {
        // Called when a player swipes a cell with the card that cell represents
        
        container.call("pick", currentPlayer, card, handler: nil)
    }
}
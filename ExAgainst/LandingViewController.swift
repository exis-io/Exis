//
//  LandingViewController.swift
//  FabAgainst
//
//  Created by Damouse on 9/29/15.
//  Copyright © 2015 paradrop. All rights reserved.
//

//  First controller to be presented, implements login and game selection.
//
//  Connections to the fabric are established in the login method. Once a login has occured
//  users can touch play, triggering the startPlaying method. Since a room of play can only include a
//  handful of players and the app should be playable by anyone

import UIKit
import Riffle
import Spring
import IHKeyboardAvoiding
import LTMorphingLabel


class LandingViewController: UIViewController, RiffleDelegate {
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var viewLogo: SpringView!
    @IBOutlet weak var viewButtons: SpringView!
    @IBOutlet weak var viewLogin: SpringView!
    @IBOutlet weak var textfieldUsername: UITextField!
    @IBOutlet weak var labelTips: LTMorphingLabel!
    
    var app: RiffleDomain!
    var me: RiffleDomain!
    var container: RiffleDomain!
    
    
    let tips = [
        "Swipe right to pick a card",
        "Each round a new player picks the winner",
        "Check out exis.io",
        "Creative Commons BY-NC-SA 2.0 license."
    ]
    
    override func viewWillAppear(animated: Bool) {
//        Riffle.setDevFabric()
//        Riffle.setDebug()
        
        IHKeyboardAvoiding.setAvoidingView(viewLogin)
        
        textfieldUsername.layer.borderColor = UIColor.whiteColor().CGColor
        textfieldUsername.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        viewLogo.animate()
        viewLogin.animate()
        
        labelTips.morphingEffect = .Scale
        labelTips.text = tips[0]
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("rotateText"), userInfo: nil, repeats: true)
    }
    
    
    func startPlaying(cards: [String], players: [Player], state: String, room: String) {
        // Result of the call to the Room when a player starts playing
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("game") as! GameViewController
        
        controller.currentPlayer = players.filter { $0.domain == self.me.domain }[0]
        controller.currentPlayer.hand = cards
        controller.players = players
        
        controller.state = state
        controller.me = self.me
        controller.app = self.app
        controller.room = RiffleDomain(name: room, superdomain: container)
        
        presentControllerTranslucent(self, target: controller)
    }
    
    
    func onJoin() {
        print("Agent joined")
        
        viewLogin.animation = "zoomOut"
        viewLogin.animate()
        viewButtons.animation = "zoomIn"
        viewButtons.animate()
    }
    
    func onLeave() {
        print("Agent left")
    }
    
    @IBAction func login(sender: AnyObject) {
        textfieldUsername.resignFirstResponder()
        let name = textfieldUsername.text!
        
        app = RiffleDomain(domain: "xs.demo.damouse.cardsagainst")
        container = RiffleDomain(name: "Osxcontainer.gamelogic", superdomain: app)
        
        // FIXME
        me = RiffleDomain(name: name, superdomain: app)
        //me = RiffleDomain(name: "user", superdomain: app)
        me.delegate = self
        
        //me.join("yG9FySWBR1KdgcLaBTrqONHBBZ3r0WtVW6Z/g1cHuTSylanEcs8mrwbh3rLAq87TNXbMOMn2PH7tftaFZyWWAUTs1iDTwsvQ6MpKKAa3CIFB0vFVYWmnCj6xb057TAuHWRdCXZ2RHtzq9Mnzwjwgu6P2pJCJbuHRWzN1CizWUsU=")
        
        me.join()
    }
    
    @IBAction func play(sender: AnyObject) {
        container.call("play", me.domain, handler: startPlaying)
    }
    
    func rotateText() {
        labelTips.text = tips[(tips.indexOf(labelTips.text)! + 1) % (tips.count)]
    }
}
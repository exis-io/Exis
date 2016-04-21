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


class LandingViewController: UIViewController, Delegate {
    @IBOutlet weak var textfieldUsername: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var viewLogo: SpringView!
    @IBOutlet weak var viewButtons: SpringView!
    @IBOutlet weak var viewLogin: SpringView!
    @IBOutlet weak var labelTips: LTMorphingLabel!
    
    var app: Domain!
    var me: Domain!
    var container: Domain!
    
    
    override func viewWillAppear(animated: Bool) {
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(rotateText), userInfo: nil, repeats: true)
        textfieldUsername.layer.borderColor = UIColor.whiteColor().CGColor
        textfieldUsername.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        IHKeyboardAvoiding.setAvoidingView(viewLogin)
        viewLogo.animate()
        viewLogin.animate()
        
        labelTips.morphingEffect = .Scale
        labelTips.text = tips[0]
        
        // Testing
        Riffle.setFabricDev()
        Riffle.setLogLevelInfo()
    }
    
    func onJoin() {
        viewLogin.animation = "zoomOut"
        viewLogin.animate()
        viewButtons.animation = "zoomIn"
        viewButtons.animate()
    }
    
    func onLeave() {
        print("Domain left")
    }
    
    @IBAction func login(sender: AnyObject) {
        textfieldUsername.resignFirstResponder()

        app = Domain(name: "xs.demo.exis.cardsagainst")
        container = Domain(name: "Osxcontainer.gamelogic", superdomain: app)
        
        me = Domain(name: textfieldUsername.text!, superdomain: app)
        me.delegate = self
        me.join()

    }
    
    @IBAction func play(sender: AnyObject) {
        container.call("play").then { (cards: [String], players: [Player], state: String, room: String) in
            
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("game") as! GameViewController
            controller.currentPlayer = getPlayer(players, domain: self.me.name)
            controller.currentPlayer.hand = cards
            controller.players = players
            
            controller.state = state
            controller.me = self.me
            controller.app = self.app
            controller.room = Domain(name: room, superdomain: self.container)
            
            // Gives the dealer permission to call "/draw" on us as needed
            self.app.call("xs.demo.Bouncer/setPerm", self.container.name, self.me.name + "/draw")
            presentControllerTranslucent(self, target: controller)
        }
    }
    
    func rotateText() {
        labelTips.text = tips[(tips.indexOf(labelTips.text)! + 1) % (tips.count)]
    }
}
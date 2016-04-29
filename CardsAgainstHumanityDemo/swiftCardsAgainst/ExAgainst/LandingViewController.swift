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


class LandingViewController: UIViewController, DomainDelegate {
    @IBOutlet weak var textfieldUsername: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var viewLogo: SpringView!
    @IBOutlet weak var viewButtons: SpringView!
    @IBOutlet weak var viewLogin: SpringView!
    @IBOutlet weak var labelTips: LTMorphingLabel!
    
    var app: AppDomain!
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
        
        app = AppDomain(name: "xs.demo.exis.cardsagainst")
        container = Domain(name: "Osxcontainer.gamelogic", superdomain: app)
        app.delegate = self
        
        
        // Always try to reconnect right away. If it succeeds, then a prebious session was found
        app.reconnect().then { (name: String) in
            print("Reconnecting as \(name)")
            self.me = Domain(name: name, superdomain: self.app)
            self.me.join()
        }.error { err in
            print("Reconnection failed. \(err)")
        }
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
        
        me = Domain(name: textfieldUsername.text!, superdomain: app)
        
        app.login(textfieldUsername.text!).error { reason in
            print("Login failed: ", reason)
        }
    }
    
    @IBAction func play(sender: AnyObject) {
        let dogs = [Dog(), Dog(), Dog()]
        let dog = dogs[0]
        
        container.call("registerModelArrays", dogs).then { (d: [Dog]) in
            assert(d[0].name == dog.name && d[0].age == dog.age && d[0].something == dog.something && dog.alive == d[0].alive)
        }.error { reason in
            print("FAILURE ON CALL RETURN --- 2-9")
            print("\tREASON: \(reason)")
        }
        
//        container.call("play").then { (cards: [String], players: [Player], state: String, room: String) in
//            print("Play call returned!")
//            
//            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("game") as! GameViewController
//            controller.currentPlayer = getPlayer(players, domain: self.me.name)
//            controller.currentPlayer.hand = cards
//            controller.players = players
//            
//            controller.state = state
//            controller.me = self.me
//            controller.app = self.app
//            controller.room = Domain(name: room, superdomain: self.container)
//            
//            // Gives the dealer permission to call "/draw" on us as needed
//            self.app.call("xs.demo.Bouncer/setPerm", self.container.name, self.me.name + "/draw")
//            presentControllerTranslucent(self, target: controller)
//        }.error { reason in
//            print("Play call failed: \(reason)")
//        }
    }
    
    func rotateText() {
        labelTips.text = tips[(tips.indexOf(labelTips.text)! + 1) % (tips.count)]
    }
}
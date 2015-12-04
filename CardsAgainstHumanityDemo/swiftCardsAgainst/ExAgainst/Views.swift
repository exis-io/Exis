//
//  Views.swift
//  FabAgainst
//
//  Created by Damouse on 10/9/15.
//  Copyright © 2015 paradrop. All rights reserved.
//
//  This is UI and UX code. It does not rely on any fabric functionality.

import Foundation
import Riffle
import RMSwipeTableViewCell
import M13ProgressSuite
import Spring


class CardTableDelegate: NSObject, UITableViewDelegate, UITableViewDataSource, RMSwipeTableViewCellDelegate {
    var cards: [String] = []
    var table: UITableView
    var parent: GameViewController
    
    
    init(tableview: UITableView!, parent p: GameViewController) {
        table = tableview
        parent = p
        super.init()
        
        table.delegate = self
        table.dataSource = self
        table.estimatedRowHeight = 100
        table.rowHeight = UITableViewAutomaticDimension
    }
    
    func refreshCards(newCards: [String]) {
        cards = newCards
        table.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("card") as! CardCell
        cell.delegate = self
        cell.labelTitle.text = cards[indexPath.row]
        
        let backView = UIView(frame: cell.frame)
        backView.backgroundColor = UIColor.clearColor()
        cell.backgroundView = backView
        
        cell.backgroundColor = UIColor.clearColor()
        cell.backViewbackgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func swipeTableViewCell(swipeTableViewCell: RMSwipeTableViewCell!, didSwipeToPoint point: CGPoint, velocity: CGPoint) {
        let cell = swipeTableViewCell as! CardCell
        
        let index = table.indexPathForCell(cell)
        let card = cards[index!.row]
        
        if point.x >= CGFloat(70.0) || point.x <= (-1 * CGFloat(70.0)) {
            cell.resetContentView()
            cell.interruptPanGestureHandler = true
            parent.playerSwiped(card)
        }
    }
    
    func removeCellsExcept(keep: [String]) {
        // removes all cards from the tableview and the table object except those passed
        
        var ret: [NSIndexPath] = []
        
        for i in 0...(cards.count - 1) {
            if !keep.contains(cards[i]) {
                ret.append(NSIndexPath(forRow: i, inSection: 0))
            }
        }
        
        cards = keep
        table.deleteRowsAtIndexPaths(ret, withRowAnimation: .Left)
    }
}


class PlayerCollectionDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate  {
    var players: [Player] = []
    var collection: UICollectionView
    var parent: GameViewController
    var appName: String
    var activeCell: PlayerCell?
    
    init(collectionview: UICollectionView, parent p: GameViewController, baseAppName: String) {
        collection = collectionview
        parent = p
        appName = baseAppName
        super.init()
        
        collection.delegate = self
        collection.dataSource = self
    }
    
    func flashCell(target: Player) {
        var index = 0
        
        for i in 0...players.count {
            if players[i].domain == target.domain {
                index = i
                break
            }
        }
        
        let cell = collection.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
        
        if let playerCell = cell as? PlayerCell {
            print(cell)
            print("TARGET: \(target), cell: \(cell)")
            
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                playerCell.viewBackground.backgroundColor = UIColor.whiteColor()
            }) { (_ :Bool) -> Void in
                playerCell.viewBackground.backgroundColor = UIColor.blackColor()
            }
        }
    }
    
    func refreshPlayers(incoming: [Player]) {
        players = incoming
        collection.reloadData()
    }
    
    func setCzar(target: Player) {
        if activeCell != nil {
            activeCell!.viewBackground.backgroundColor = UIColor.clearColor()
        }
        
        var index = 0
        for i in 0...players.count {
            if players[i] == target {
                index = i
                break
            }
        }
        
        let c = collection.cellForItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
        
        if c != nil {
            if let cell = c as? PlayerCell {
                activeCell = cell
                activeCell!.viewBackground.backgroundColor = UIColor.grayColor()
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("player", forIndexPath: indexPath) as! PlayerCell
        let player = players[indexPath.row]
        
        cell.labelName.text = player.domain.stringByReplacingOccurrencesOfString(appName + ".", withString: "")
        cell.labelScore.text = "\(player.score)"
        cell.viewBackground.layer.borderColor = UIColor.whiteColor().CGColor
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: parent.view.frame.size.width / 2, height: 40)
    }
}


class CardCell: RMSwipeTableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewHolder: UIView!
    
    func resetContentView() {
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.contentView.frame = CGRectOffset(self.contentView.bounds, 0.0, 0.0)
        }) { (b: Bool) -> Void in
            self.shouldAnimateCellReset = true
            self.cleanupBackView()
            self.interruptPanGestureHandler = false
            self.panner.enabled = true
        }
    }
}


class PlayerCell: UICollectionViewCell {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var labelScore: UILabel!
}


// A simple subclass of the progress views that ticks down over time
class TickingView: M13ProgressViewBar {
    var timer: NSTimer?
    var current: Double = 1.0
    var increment: Double = 0.1
    let tickRate = 0.1
    
    func countdown(time: Double) {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
        self.primaryColor = UIColor.whiteColor()
        self.secondaryColor = UIColor.blackColor()
        
        increment = tickRate / time
        current = 1.0
        self.setProgress(CGFloat(current), animated: true)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(tickRate, target: self, selector: Selector("tick"), userInfo: nil, repeats: true)
    }
    
    func tick() {
        current -= increment
        
        if current <= 0 {
            timer?.invalidate()
            timer = nil
            current = 1.0
        } else {
            self.setProgress(CGFloat(current), animated: true)
        }
    }
}


func presentControllerTranslucent(source: UIViewController, target: UIViewController) {
    // Presents the target view contoller translucently
    let effect = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    effect.frame = target.view.frame
    target.view.insertSubview(effect, atIndex:0)
    
    target.modalPresentationStyle = .OverFullScreen
    source.modalPresentationStyle = .CurrentContext
    source.presentViewController(target, animated: true, completion: nil)
}

func blur(target: UIView) {
    let effect = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    effect.frame = target.bounds
    effect.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    target.insertSubview(effect, atIndex:0)

}

func flashView(view: SpringView, label: UILabel, text: String) {
    label.text = text
    view.animation = "fadeIn"
    view.animate()
    
    view.animateNext {
        view.animation = "fadeOut"
        view.animate()
    }
}





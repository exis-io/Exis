//
//  Riffle.swift
//  Pods
//
//  Created by Mickey Barboi on 9/25/15.
//
//

import Foundation
//import MDWamp

public class BlinkingLabel : UILabel {
    public func startBlinking() {
        let options : UIViewAnimationOptions = UIViewAnimationOptions.Repeat
        UIView.animateWithDuration(0.25, delay:0.0, options:options, animations: {
            self.alpha = 0
        }, completion: nil)
        
//        let w = MDWamp()
    }
    
    public func stopBlinking() {
        alpha = 1
        layer.removeAllAnimations()
    }
}

//class RiffleSession: NSObject, MDWampClientDelegate {
//}
//
//  ViewController.swift
//  RiffleTesterIos
//
//  Created by Mickey Barboi on 11/22/15.
//  Copyright © 2015 exis. All rights reserved.
//

import UIKit

let url = "ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws"
let domain = "xs.damouse"



class ViewController: UIViewController {
    override func viewDidAppear(animated: Bool) {
//        let ret = GoRiffleEPConnector(url, domain)
//        
//        print(String.fromCString(ret))
//        
//        GoRifflePSubscribe("xs.damouse.go/sub")
//        
//        // Threading implementation
//        let s = Spinner()
//        
//        // Means to let the library do its thing while we listen
//        let thread = NSThread(target: s, selector: "doThings", object: nil)
//        thread.start()
    }
}

//class Spinner: NSObject {
//    func doThings() {
//        while true {
//            let a = String.fromCString(GoRifflePReceive())
//            print("Message: \(a)")
//        }
//    }
//}

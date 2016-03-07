//
//  ViewController.swift
//  Riffle
//
//  Created by Damouse on 09/25/2015.
//  Copyright (c) 2015 Mickey Barboi. All rights reserved.
//

import UIKit
import Riffle 

class ViewController: UIViewController {
    override func viewDidLoad() {
        SetLogLevelDebug()
        SetFabricSandbox()
        
        super.viewDidLoad()
        
        print("viewDidLoad")
    }
}

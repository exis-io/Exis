//
//  OsxBug.swift
//  Riffle
//
//  Created by damouse on 4/25/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Riffle

class Rat: Model {
    var name = "Joe"
//    var age = 100
}

class OsxBugPlayground {
    init() {}
    
    func test() {
        let r = dmtest(Rat.self)
        print("Result \(r?.description)")
        
//        for i in 0...5 {
//            let r = dmtest(Rat.self)
//            print("Result \(i): \(r?.name)")
//        }
    }
}
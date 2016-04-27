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
    var age = 100
}

class OsxBugPlayground {
    init() {}
    
    func test() {
        
        // Waiting for an internal deferred to resolve
//        var d: DeferredChain = BaseDeferred()
//        let f = BaseDeferred() // Some operation that returns a deferred, mocked
//        
//        f.then {
//            let a = 2
//            print(a)
//        }
//        
//        d.then {
//            let a = 1
//            print(a)
//            return f
//        }.then {
//            let b = 3
//            print(b)
//        }
//        
        
        let d = DeferredParams<Int>()
        
        d.then { s in
            print("Have s!")
        }.then {
            let b = 2
        }.error { err in
            print(err)
        }
        
        d.callback(["asdf"])

//        
//        d.callback([])
//        f.callback([])
//        
//
//        let d = Deferred()
//        let m = Deferred()
//        
////        d.then {
////            print("In d")
////            return m
////        }.then {
////            print("d is done")
////        }
//        
//        m.then {
//            print("In m")
//        }
//        
//        m.callback([])
//        d.callback([])
//        
//        let r = dmtest(Rat.self)
//        print("Result \(r?.description)")
//        
//        for i in 0...5 {
//            let r = dmtest(Rat.self)
//            print("Result \(i): \(r?.name)")
//        }
    }
}
//
//  main.swift
//  Backend
//
//  Created by damouse on 3/7/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Riffle

// Required helper method for OSX backends
initTypes(External(String.self, String.self), External(Int.self, Int.self), External(Double.self, Double.self), External(Float.self, Float.self), External(Bool.self, Bool.self))

Riffle.setLogLevelInfo()
Riffle.setFabricDev()

// This is faking two seperate connections by creating another top level domain
// Not intended for regular use

//let app = AppDomain(name: "xs.tester")
//app.login()

let app2 = AppDomain(name: "xs.tester")
let receiver2 = Domain(name: "receiver", superdomain: app2)
let sender2 = Sender(name: "sender", superdomain: app2, peer: receiver2)

let app = AppDomain(name: "xs.tester")
let receiver = Receiver(name: "receiver", superdomain: app, done: {
    app2.login()
})

app.login()

//app.listen()

NSRunLoop.currentRunLoop().run()

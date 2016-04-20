//
//  main.swift
//  Backend
//
//  Created by damouse on 3/7/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//


import Riffle

// Required helper method for OSX targets
osxConvertible = { a in guard let z = a as? Convertible else { return nil }; return z }
osxProperty = { a in guard let z = a as? Property else { return nil }; return z }

initTypes(External(String.self, String.self), External(Int.self, Int.self), External(Double.self, Double.self), External(Float.self, Float.self), External(Bool.self, Bool.self))

//let str = "12345"
//let i = 1234
//
////checkConvertible(str)
////checkConvertible(i)
//
//let arr: [Int] = [1, 2, 3]
//
//checkCollection(arr)


Riffle.setLogLevelInfo()
Riffle.setFabricDev()

print("Starting Tests")

// This is faking two seperate connections by creating another top level domain
// Not intended for regular use
let app = Domain(name: "xs.tester")
let receiver = Receiver(name: "receiver", superdomain: app)

let app2 = Domain(name: "xs.tester")
let sender2 = Sender(name: "sender", superdomain: app2)
let receiver2 = Receiver(name: "receiver", superdomain: app2)

sender2.receiver = receiver2

receiver.joinFinished = {
    sender2.join()
}

receiver.join()

NSRunLoop.currentRunLoop().run()

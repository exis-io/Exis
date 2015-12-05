//: Playground - noun: a place where people can play

import Cocoa

var a = [1, 2, 3]

class Test {
    var cards = a
}

let t = Test()
let c = Test()

t.cards.append(4)
c.cards
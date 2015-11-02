//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

protocol Boo {}
extension Int: Boo {}

let x = [1, 2, 3]

let y = x as! AnyObject
print(y)

if let z = y as? [AnyObject] {
    print(z)
    
    if let a = z as? [Int] {
        print(a)
    }
}

if let b = y as? [Boo] {
    print(b)
}
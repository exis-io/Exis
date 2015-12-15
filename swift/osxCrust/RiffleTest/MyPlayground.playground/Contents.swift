//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

let a = { (a: Int) in
//    return "A"
}

let b = { (a: Int) -> [String] in
    return ["B", "C"]
}

func receiver(fn: (Any) -> ()) {
    print(fn)
    
//    let m = Mirror(reflecting: fn)
//    print(m)
//    m.description
}


receiver(a)
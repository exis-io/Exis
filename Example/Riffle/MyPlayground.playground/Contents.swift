//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

func arrayForTuple<T>(tuple: Any?, _ returnType: T.Type) -> [T]? {
    if tuple == nil {
        return nil
    }
    
    let reflection = Mirror(reflecting: tuple!)
    var arr : [T] = []
    
    for value in reflection.children {
        if let val = value.value as? T {
            arr.append(val)
        } else {
            return nil
        }
    }
    
    return arr
}

func f() -> (Int, String) {
    return (3, "")
}

let b = f()
arrayForTuple(b, Any.self)

let a = (1, 2)
let converted = arrayForTuple(a, Any.self)
print(converted)


let x: Int = 1
var result: Float?

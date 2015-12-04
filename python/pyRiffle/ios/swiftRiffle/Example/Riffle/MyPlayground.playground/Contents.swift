//: Playground - noun: a place where people can play

import Cocoa

// Playing with the operators
infix operator |+ {
associativity right
precedence 155
}

infix operator |- {
associativity right
precedence 155
}

func |+ (a: Deferred, b: () -> ()) -> Deferred {
    return Deferred()
}

func |- (a: Deferred, b: () -> ()) -> Deferred {
    return Deferred()
}


func succ() {}
func err() {}


// Playing with how deferreds look
// Each deferred returns a deferred
// Each


class Deferred {
    var callback: Deferred?
    var errback: Deferred?
    
    init() {
        
    }
    
    func success() -> Deferred {
        return Deferred()
    }
    
    func failure() -> Deferred {
        return Deferred()
    }
}

func call() -> Deferred {
    return Deferred()
}

func register() -> Deferred {
    return Deferred()
}


let a = call() |+ {
    print("Success!")
}


// IaaS- using VMs
// PaaS- interacting with code
// CaaS- ???




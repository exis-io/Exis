//
//  DeferredTesting.swift
//  Riffle
//
//  Created by damouse on 4/27/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Riffle

// Examples and Inline tests
func deferredTest() {

    // Default, no args errback and callback
    _ = {
        let d = Defered<Void>()
        
        d.then {
            print("Default Then")
        }
        
        d.callback([])
        
        d.error { r in
            print("DefaultError")
        }
        
        d.errback(["Asdf"])
    }()


    // Default chaining
    _ = {
        let d = Defered<Void>()
        
        d.then {
            print(1)
        }.then {
            print(2)
        }
        
        d.callback([])
        
        d.error { e in
            print(3)
        }.error { e in
            print(4)
        }
        
        d.errback([""])
    }()


    // Lazy callbacks- immediately fire callback handler if the chain has already been called back
    _ = {
        var d = Defered<Void>()
        d.callback([])
        
        d.then {
            print(1)
        }.then {
            print(2)
        }
        
        d.errback([""])
        
        d.error { e in
            print(1)
        }.error { e in
            print(2)
        }
    }()


    // Waiting for an internal Defered to resolve
    _ = {
        var d = Defered<Void>()
        let f = Defered<Void>()
        
        // This is pretty close, but not quite there
        f.then { s in
            print(2)
        }
        
        d.chain {
            print(1)
            return f
        }.then {
            print(3)
        }
        
        d.callback([])
        f.callback(["Hello"])
    }()


    // Param constraints
    _ = {
        var d = Defered<()>()
        var e = Defered<String>()
        
        d.chain { () -> Defered<String> in
            print(1)
            return e
        }.then { s in
            print("Have", s)
            print(2)
        }
        
        d.callback([1])
        e.callback(["Done!"])
    }()


    // A Mix of the above two. Given a Defered that returns value in some known
    // type, returning that Defered should chain the following then as a callback of the appropriate type
    _ = {
        var d = Defered<Void>()
        let f = Defered<String>()
        
        d.chain { () -> Defered<String> in
            print(1)
            return f
        }.then { s in
            print(s)
            print(2)
        }.then {
            print(3) // I dont take any args, since the block above me didnt reutn a Defered
        }.error { err in
            print("Error: \(err)")
        }
        
        d.callback([])
        // f.callback(["Hello"])
        f.errback(["early termination"])
    }()


    // Chaining Defereds twice
    _ = {
        var d = Defered<Void>()
        let f = Defered<String>()
        let c = Defered<Bool>()
        
        d.chain { () -> Defered<String> in
            print(1)
            return f
        }.chain { str -> Defered<Bool> in
            print(2, str)
            return c
        }.then { bool in
            print(3, bool)
        }.error { err in
            print("Error: \(err)")
        }
        
        // Comment out lines below and make sure the prints do or dont show up in order
        d.callback([])
        f.callback(["Hello"])
        c.callback([true])
        // f.errback(["early termination"])
    }()

}
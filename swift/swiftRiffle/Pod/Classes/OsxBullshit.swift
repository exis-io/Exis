//
//  OsxBullshit.swift
//  Pods
//
//  Created by damouse on 4/12/16.
//
// See in swift repo: lib/irgen/runtimeFunctions
// Looks like you might be able to hook with "MSHookFunciton"
// Also check out stdlib/public/runtime/reflection, but I dont think these are accessible
// Maybe try a mirror with this?

import Foundation

// Just playing around with the OSX bug
public func updownTypes<A: Convertible>(a: A) {
    // Interestingly, this may work reasonably well when typechecking for our reflection
    // Generates a unique thingy
    // let z = ObjectIdentifier(a.dynamicType)
    // print("Suck it: \(z)")
    
    if let z = a as? Int {
        print("Got the int")
    }
    
    else if let z = a as? Convertible {
        print("Convertible Check ")
    }
        
    else if let z = osxConvertible!(a) {
        print("Caught the check on external")
    }
    
    else {
        print("Check failed!")
    }
}
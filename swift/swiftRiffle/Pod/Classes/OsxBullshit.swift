
//
//  OsxBullshit.swift
//  Pods
//
//  Created by damouse on 4/12/16.
//
//

import Foundation

// An application-exportable converter function that allows osx targets to cast appropriately
// Does this look silly or wrong to you? Good, you're a sane swift developer. 
// Unfortunatly, type checking with a swift framework on OSX is not a sane endeveour. Trust 
// me when I say there's an outrageous amount of nonsense going on behind the scenes here
public var osxTypeHelper: (Convertible) -> Convertible? = { (a: Convertible) -> Convertible? in
    if let z = a as? Convertible {
        return z
    }
    
    return nil
}


public func testType<T: Convertible>(a: T) {
    if let c = osxTypeHelper(a) {
        print("SUCCESS!")
    } else {
        print("FAILED")
    }
}

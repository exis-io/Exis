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


// An application-exportable converter function that allows osx targets to cast appropriately
// Does this look silly or wrong to you? Good, you're a sane swift developer.
// Unfortunatly, type checking with a swift framework on OSX is not a sane endeveour. Trust
// me when I say there's an outrageous amount of subtle nonsense going on here
// TODO: put an error log detailing what to put in here if the block hasn't been assigned on OSX

// This isn't needed anymore, but crashes
public var osxConvertible: ((Convertible) -> Convertible?)?
public var osxProperty: ((Property) -> Property?)?

var externalInt: Int.Type = Int.self
public var externalString: Any.Type? = String.self
var externalBool: Bool.Type = Bool.self
var externalDouble: Double.Type = Double.self
var externalFloat: Float.Type = Float.self

// The publics CANNOT be typed as library types-- have to be Any.Type. We still need to retain this variable
// for the unsafebitcast
public var externalStringAny: String.Type = String.self

public func setup(a: Int.Type, _ b: String.Type, _ c: Bool.Type, _ d: Double.Type, _ e: Float.Type) {
    externalInt = a
    externalString = b
    externalBool = c
    externalDouble = d
    externalFloat = e
}


// Just playing around with the OSX bug
public func updownTypes<A>(a: A) {
    // Interestingly, this may work reasonably well when typechecking for our reflection
    // Generates a unique thingy
    // let z = ObjectIdentifier(a.dynamicType)
    // print("Suck it: \(z)")
    
    var c: Convertible?
    
    if A.self == externalInt {
        c = unsafeBitCast(a, externalInt)
    } else if A.self == externalString {
        c = unsafeBitCast(a, externalStringAny)
    } else if a.dynamicType == externalBool {
        print("Have Int!")
    } else if a.dynamicType == externalDouble {
        print("Have Int!")
    } else if a.dynamicType == externalFloat {
        print("Have Int!")
    } else {
        print("Type not found!")
    }
    
    print("Have final convertible: \(c)")

//    print("Incoming type is the same as the other type: \(A.self) \(externalString!.self) \(A.self == externalString!)")
    
    // Ok, we can import external types on OSX and do a hard check between the types
//    let z = unsafeBitCast(a, externalString!)
//    let q = unsafeBitCast(a, String.self)
//    
//    print("Hard cast worked! \(z)")
//    
//    if let q = z as? Convertible {
//        print("Hard cast convertible check ok!")
//    }
//    
//    let type = externalTypes.filter { $0 == a.dynamicType }
//    print("Found type: \(type)")
//    let cast = unsafeBitCast(a, type[0])
//    print("A convertible was found: \(cast)")
//    
//    if let z = a as? Int {
//        print("Got the int")
//    }
//    
//    else if let z = a as? Convertible {
//        print("Convertible Check")
//    }
//        
////    else if let z = osxConvertible!(a) {
////        print("Caught the check on external")
////    }
////    
//    else {
//        print("Check failed!")
//    }
}
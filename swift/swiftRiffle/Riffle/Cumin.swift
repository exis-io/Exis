//
//  Cumin.swift
//  RiffleTest
//
//  Created by damouse on 12/28/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation

// Converter operator. Attempts to convert the object on the right to the type given on the left
// Just here to make the cumin conversion functions just the smallest bit clearer
infix operator <- {
associativity right
precedence 155
}


func <- <T: Property> (t:T.Type, object: Any) -> T {
    return T.deserialize(object) as! T
}

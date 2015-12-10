//
//  Utils.swift
//  RiffleTest
//
//  Created by damouse on 12/9/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation

extension String {
    func cString() -> UnsafeMutablePointer<Int8> {
        let cs = (self as NSString).UTF8String
        return UnsafeMutablePointer(cs)
    }
}
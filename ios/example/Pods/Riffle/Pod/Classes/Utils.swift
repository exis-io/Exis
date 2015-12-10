//
//  Utils.swift
//  Pods
//
//  Created by Mickey Barboi on 11/7/15.
//
//

import Foundation

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

func env(key: String, _ normal: String) -> String {
    if let result = NSProcessInfo.processInfo().environment[key] {
        return result
    } else {
        Riffle.debug("Unable to extract environment variable \(key). Using \(normal) instead")
        return normal
    }
}

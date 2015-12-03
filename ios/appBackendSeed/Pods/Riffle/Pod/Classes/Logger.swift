//
//  File.swift
//  Pods
//
//  Created by damouse on 11/5/15.
//
//

import Foundation

public class RiffleLogger {
    public var DEBUG = false
    
    func debug(s: String) {
        if DEBUG {
            print(s)
        }
    }
    
    func warn(s: String) {
        print("WARN: \(s)")
    }
    
    func panic(s: String) {
        print("PANIC: \(s)")
    }
}
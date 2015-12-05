//
//  Deferred.swift
//  Pods
//
//  Created by damouse on 12/4/15.
//
//  Homebaked, python Twisted inspired deferreds.
//


import Foundation


public class Deferred {
    var _callback: (() -> ())?
    var _errback: (() -> ())?
    
    var fired = false
    
    func succeed() {
        if let cb = _callback {
            fired = true
            cb()
        }
    }
    
    func fail() {
        if let cb = _errback {
            fired = true
            cb()
        }
    }
    
    func callback(cb: () -> ()) {
        _callback = cb
    }
    
    func errback(cb: () -> ()) {
        _errback = cb
    }
}
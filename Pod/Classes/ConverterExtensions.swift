//
//  ConverterExtensions.swift
//  Pods
//
//  Created by Mickey Barboi on 10/27/15.
//
//  Extensions for cumin classes that implement conversions between serialized forms and method signature forms.


import Foundation

public protocol Cuminicable {
    static func convert(object: AnyObject) -> Cuminicable?
}

public typealias CN = Cuminicable

extension Int: Cuminicable {
    public static func convert(object: AnyObject) -> Cuminicable? {
        if let x = object as? Int {
            return x
        }
        
        if let x = object as? String {
            return Int(x)
        }
        
        return nil
    }
}

extension String: Cuminicable {
    public static func convert(object: AnyObject) -> Cuminicable? {
        if let x = object as? String {
            return x
        }
        
        if let x = object as? Int {
            return String(x)
        }
        
        return nil
    }
}

extension Double: Cuminicable {
    public static func convert(object: AnyObject) -> Cuminicable? {
        if let x = object as? Double {
            return x
        }
        
        if let x = object as? Int {
            return Double(x)
        }
        
        return nil
    }
}

extension Float: Cuminicable {
    public static func convert(object: AnyObject) -> Cuminicable? {
        if let x = object as? Float {
            return x
        }
        
        if let x = object as? Int {
            return Float(x)
        }
        
        return nil
    }
}

extension Bool: Cuminicable {
    public static func convert(object: AnyObject) -> Cuminicable? {
        if let x = object as? Bool {
            return x
        }
        
        if let x = object as? Int {
            return Bool(x)
        }
        
        return nil
    }
}

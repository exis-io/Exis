//
//  Extensions.swift
//  SwiftRiffle
//
//  Created by damouse on 12/29/15.
//  Copyright © 2015 Exis. All rights reserved.
//

import Foundation

#if os(Linux)
    import SwiftGlibc
    import Glibc
#else
    import Darwin.C
#endif

// All properties implement Convertible, but Models react differently 
// This allows each property to handle its construction differently
public protocol Convertible {
    static func isModel() -> Bool
    
    // Return a constructed form of this object
    static func create(from: Any) -> Any
}

public protocol BaseConvertible: Convertible {}

extension BaseConvertible {
    public static func isModel() -> Bool {
        return false
    }
    
    public static func create(from: Any) -> Any {
        return from
    }
}

/// All model properties must conform to this protocol
public protocol Property: Convertible {}

extension Property {
    
    static func size() -> Int {
        return Int(ceil(Double(sizeof(self))/Double(sizeof(Int))))
    }
    
    static func type() -> Self.Type.Type {
        return self.dynamicType
    }
    
    mutating func codeInto(pointer: UnsafePointer<Int>) {
        (UnsafeMutablePointer(pointer) as UnsafeMutablePointer<Self>).memory = self
    }
    
    mutating func codeOptionalInto(pointer: UnsafePointer<Int>) {
        (UnsafeMutablePointer(pointer) as UnsafeMutablePointer<Optional<Self>>).memory = self
    }
}

protocol OptionalProperty : Property {
    static func codeNilInto(pointer: UnsafePointer<Int>)
    static func propertyType() -> Property.Type?
    func property() -> Property?
}

extension Optional : OptionalProperty {
    
    static func codeNilInto(pointer: UnsafePointer<Int>) {
        (UnsafeMutablePointer(pointer) as UnsafeMutablePointer<Optional>).memory = nil
    }
    
    static func propertyType() -> Property.Type? {
        return Wrapped.self as? Property.Type
    }
    
    func property() -> Property? {
        switch self {
        case .Some(let property):
            if let property = property as? Property {
                return property
            } else {
                return nil
            }
        default: return nil
        }
    }
}

/// Structures

extension AnyBidirectionalCollection : Property, BaseConvertible {}
extension AnyBidirectionalIndex : Property, BaseConvertible {}
extension AnyForwardCollection : Property, BaseConvertible {}
extension AnyForwardIndex : Property, BaseConvertible {}
extension AnyRandomAccessCollection : Property, BaseConvertible {}
extension AnyRandomAccessIndex : Property, BaseConvertible {}
extension AnySequence : Property, BaseConvertible {}
extension Array : Property, BaseConvertible {}
extension ArraySlice : Property, BaseConvertible {}
// extension AutoreleasingUnsafeMutablePointer : Property, BaseConvertible {}
extension Bool : Property, BaseConvertible {}
extension COpaquePointer : Property, BaseConvertible {}
extension CVaListPointer : Property, BaseConvertible {}
extension Character : Property, BaseConvertible {}
extension ClosedInterval : Property, BaseConvertible {}
extension CollectionOfOne : Property, BaseConvertible {}
extension ContiguousArray : Property, BaseConvertible {}
extension Dictionary : Property, BaseConvertible {}
extension DictionaryGenerator : Property, BaseConvertible {}
extension DictionaryIndex : Property, BaseConvertible {}
extension DictionaryLiteral : Property, BaseConvertible {}
extension Double : Property, BaseConvertible {}
extension EmptyCollection : Property, BaseConvertible {}
extension EmptyGenerator : Property, BaseConvertible {}
extension EnumerateGenerator : Property, BaseConvertible {}
extension EnumerateSequence : Property, BaseConvertible {}
extension FlattenBidirectionalCollection : Property, BaseConvertible {}
extension FlattenBidirectionalCollectionIndex : Property, BaseConvertible {}
extension FlattenCollection : Property, BaseConvertible {}
extension FlattenCollectionIndex : Property, BaseConvertible {}
extension FlattenGenerator : Property, BaseConvertible {}
extension FlattenSequence : Property, BaseConvertible {}
extension Float : Property, BaseConvertible {}
extension GeneratorOfOne : Property, BaseConvertible {}
extension GeneratorSequence : Property, BaseConvertible {}
extension HalfOpenInterval : Property, BaseConvertible {}
extension IndexingGenerator : Property, BaseConvertible {}
extension Int : Property, BaseConvertible {}
extension Int16 : Property, BaseConvertible {}
extension Int32 : Property, BaseConvertible {}
extension Int64 : Property, BaseConvertible {}
extension Int8 : Property, BaseConvertible {}
extension JoinGenerator : Property, BaseConvertible {}
extension JoinSequence : Property, BaseConvertible {}
extension LazyCollection : Property, BaseConvertible {}
extension LazyFilterCollection : Property, BaseConvertible {}
extension LazyFilterGenerator : Property, BaseConvertible {}
extension LazyFilterIndex : Property, BaseConvertible {}
extension LazyFilterSequence : Property, BaseConvertible {}
extension LazyMapCollection : Property, BaseConvertible {}
extension LazyMapGenerator : Property, BaseConvertible {}
extension LazyMapSequence : Property, BaseConvertible {}
extension LazySequence : Property, BaseConvertible {}
extension ManagedBufferPointer : Property, BaseConvertible {}
extension Mirror : Property, BaseConvertible {}
extension MutableSlice : Property, BaseConvertible {}
extension ObjectIdentifier : Property, BaseConvertible {}
extension PermutationGenerator : Property, BaseConvertible {}
extension Range : Property, BaseConvertible {}
extension RangeGenerator : Property, BaseConvertible {}
extension RawByte : Property, BaseConvertible {}
extension Repeat : Property, BaseConvertible {}
extension ReverseCollection : Property, BaseConvertible {}
extension ReverseIndex : Property, BaseConvertible {}
extension ReverseRandomAccessCollection : Property, BaseConvertible {}
extension ReverseRandomAccessIndex : Property, BaseConvertible {}
extension Set : Property, BaseConvertible {}
extension SetGenerator : Property, BaseConvertible {}
extension SetIndex : Property, BaseConvertible {}
extension Slice : Property, BaseConvertible {}
extension StaticString : Property, BaseConvertible {}
extension StrideThrough : Property, BaseConvertible {}
extension StrideThroughGenerator : Property, BaseConvertible {}
extension StrideTo : Property, BaseConvertible {}
extension StrideToGenerator : Property, BaseConvertible {}
extension String : Property, BaseConvertible {}
extension String.CharacterView : Property, BaseConvertible {}
extension String.CharacterView.Index : Property, BaseConvertible {}
extension String.UTF16View : Property, BaseConvertible {}
extension String.UTF16View.Index : Property, BaseConvertible {}
extension String.UTF8View : Property, BaseConvertible {}
extension String.UTF8View.Index : Property, BaseConvertible {}
extension String.UnicodeScalarView : Property, BaseConvertible {}
extension String.UnicodeScalarView.Generator : Property, BaseConvertible {}
extension String.UnicodeScalarView.Index : Property, BaseConvertible {}
extension UInt : Property, BaseConvertible {}
extension UInt16 : Property, BaseConvertible {}
extension UInt32 : Property, BaseConvertible {}
extension UInt64 : Property, BaseConvertible {}
extension UInt8 : Property, BaseConvertible {}
extension UTF16 : Property, BaseConvertible {}
extension UTF32 : Property, BaseConvertible {}
extension UTF8 : Property, BaseConvertible {}
extension UnicodeScalar : Property, BaseConvertible {}
extension Unmanaged : Property, BaseConvertible {}
extension UnsafeBufferPointer : Property, BaseConvertible {}
extension UnsafeBufferPointerGenerator : Property, BaseConvertible {}
extension UnsafeMutableBufferPointer : Property, BaseConvertible {}
extension UnsafeMutablePointer : Property, BaseConvertible {}
extension UnsafePointer : Property, BaseConvertible {}
extension Zip2Generator : Property, BaseConvertible {}
extension Zip2Sequence : Property, BaseConvertible {}

/// Enumerations

extension Bit : Property, BaseConvertible {}
extension FloatingPointClassification : Property, BaseConvertible {}
extension ImplicitlyUnwrappedOptional : Property, BaseConvertible {}
extension Mirror.AncestorRepresentation : Property, BaseConvertible {}
extension Mirror.DisplayStyle : Property, BaseConvertible {}
extension Optional : Property, BaseConvertible {}
extension PlaygroundQuickLook : Property, BaseConvertible {}
extension Process : Property, BaseConvertible {}
extension UnicodeDecodingResult : Property, BaseConvertible {}

/// Classes

extension AnyGenerator : Property, BaseConvertible {}
extension NonObjectiveCBase : Property, BaseConvertible {}
extension NSObject : Property, BaseConvertible {}
extension VaListBuilder : Property, BaseConvertible {}

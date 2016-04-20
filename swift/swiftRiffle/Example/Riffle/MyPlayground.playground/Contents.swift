import Foundation

let a: String.Type = String.self
let b: Any.Type = String.self

struct ExternalType<T> {
    var name: String
    var typedType: T.Type
    var ambiguousType: Any.Type
}

let externalString = ExternalType(name: "string", typedType: a, ambiguousType: b)
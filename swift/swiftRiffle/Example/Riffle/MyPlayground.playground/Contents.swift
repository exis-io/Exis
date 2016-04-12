import Foundation

public var externalInt: Int.Type?

externalInt = Int.self

public func testType(a: Any) {
    if let z = a as? Int {
        print("Native int check succeeded")
    }
    
    //    if let z = a as? externalInt.self {
    //        print("External type check")
    //    }
}
import UIKit
import XCTest
import Riffle


// Static testing methods 
func add(a: Int, b: Int) -> Int {
    return a + b
}

func nothing() {
    
}

func echo(a: String) -> String {
    return a
}

class Dog: RiffleModel {
    var name: String?
    
    // Cant implement an init! Not sure why.
}


// Cuminication tests. Ensure the cuminicated functions are able to receive the parameters they expect
class CuminTests: XCTestCase {
    func testString() {
        let c = cumin(echo)
        XCTAssertEqual(c(["a"]), "a")
    }
    
    func testNSString() {
        let c = cumin(echo)
        let oldString = NSString(string: "a")
        XCTAssertEqual(c([oldString]), "a")
    }
}


// Tests for the converter functions and related functionality
// The name of the testing function describes what we're converting from
//NOTE: These may not work as expected given that the equality may not be checking the classes
//class IntConverterTests: XCTestCase {
//    func testInt() {
//        let x: Int = 1
//        let y = 1
//        XCTAssertEqual(x, convert(y, Int.self))
//    }
//    
//    func testNumber() {
//        let x: Int = 1
//        let y = NSNumber(integer: 1)
//        XCTAssertEqual(x, convert(y, Int.self))
//    }
//}
//
//
//class StringConverterTests: XCTestCase {
//    func testString() {
//        let x: String = "hello"
//        let y = "hello"
//        XCTAssertEqual(x, convert(y, String.self))
//    }
//    
//    func testNSString() {
//        let x: String = "hello"
//        let y = NSString(string: "hello")
//        XCTAssertEqual(x, convert(y, String.self))
//    }
//}
//
//class ObjectConverterTests: XCTestCase {
//    func testSerialization() {
//        let json: [NSObject: AnyObject] = ["name": "Fido"]
//        let result = convert(json, Dog.self)!
//        
//        XCTAssertEqual(result.name, "Fido")
//    }
//}
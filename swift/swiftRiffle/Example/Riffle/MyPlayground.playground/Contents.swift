////: Playground - noun: a place where people can play
//
//import Cocoa
//import Foundation
//
///////////////////////////////////////
//// Naive example 1: no args
///////////////////////////////////////
//
//var handler1: (() -> ())? = nil
//
//func register1(endpoint: String, handler: () -> ()) {
//    // Assign the new handler to handle calls on this endpoint...
//    
//    handler1 = handler
//}
//
//
//func invoke1(endpoint: String, args: AnyObject...) {
//    // Still have to check the number of args, since any more than 0 is an error
//    if args.count != 0 {
//        print("Error, incorrect number of args")
//        return
//    }
//    
//    // No args!
//    handler1!()
//    
//    // Done!
//}
//
//register1("one") {
//    print("No args, doing nothing")
//}
//
//// invoke1("one")
//
///////////////////////////////////////
//// Naive example 2: two args
///////////////////////////////////////
//var handler2: ((Int, String) -> ())? = nil
//
//
//func register2(endpoint: String, handler: (Int, String) -> ()) {
//    // Assign the new handler to handle calls on this endpoint...
//    
//    handler2 = handler
//}
//
//func invoke2(endpoint: String, _ args: AnyObject...) {
//    // No args!
//    
//    if args.count != 2 {
//        print("Error, incorrect number of args")
//        return
//    }
//    
//    guard let firstArg = args[0] as? Int else { return }
//    guard let secondArg = args[1] as? String else { return }
//    
//    handler2!(firstArg, secondArg)
//    
//    // No return
//}
//
//register2("two") { a, b in
//    print("Got args: \(a), \(b)")
//}
//
//// invoke2("two", 1, "2")
//
//
///////////////////////////////////////
//// 
//// Real example
////
//// Problem statement, given some arbitrary handler that takes variable number
//// and types of args and return values, invoke it with arbitrary parameters
//// only if there are exactly the right number and kind of params
////
///////////////////////////////////////
//
//// How handlers are REALLY stored
//var handlers: [String: Any] = [:]
//
//func register(endpoint: String, handler: Any) {
//    // The print shows us exactly what we need to know to check in the future:
//    // => (String, Int) -> String
//    print("Handler takes types: \(handler.dynamicType)")
//    
//    handlers[endpoint] = handler
//}
//
//func invoke(endpoint: String, _ args: AnyObject...) {
//    let target = handlers[endpoint]!
//    
//    print("On invocation: \(target.dynamicType)")
//    
//    // HELP-- I should fail if the number of args or types of args
//    // dont match those in the handler!
//    
//    // target(args[0] as! ExpectedType, args[1] as! ExpectedType)
//}
//
//register("three") { (a: String, b: Int) -> String in
//    print("Im the real method!")
//    return "Hello!"
//}
//
//invoke("three", "Hello", 8)
//
///////////////////////////////////////
//// How Cumin works
///////////////////////////////////////
//func cumin<A, T>(a: A?, _ t: T.Type) -> T? {
//    print("T is the type we need: \(t)")
//    
//    if let z = a as? T {
//        print("Already have the type we need!")
//        return z
//    }
//    
//    // Have to try a conversion...
//    if let z = a as? Int {
//        print("Argument is an Int, we can cast to string!")
//        
//        return String(z) as? T
//    }
//    
//    return nil
//}
//
//cumin(1, String.self)

let t = (5, "String", false)
let z = t as! Any

print(t.dynamicType)

let mirror = Mirror(reflecting: t)
for (label, value) in mirror.children {
    print(label)
    print(value)
}




//: Playground - noun: a place where people can play

import Cocoa

// Handlers store blocks that are associated with some id. They're called when things happen
//var handler: ((AnyObject) -> ())? = nil
var handler: [String: Any] = [:]

// Take a handler block and save it for later. Need to be able to save any type of blocks: any kinds of arguments with any number of returns
func register(endpoint: String, fn: Any ) {
    handler[endpoint] = fn
}

// Given some set of arguments 
func invoke(endpoint: String, args: [AnyObject]) {
    let realHandler = handler[endpoint]
    print(realHandler)
    
    let m = Mirror(reflecting: realHandler)
    print(m)
    
    if let fn = realHandler as? ((Int, String) -> ()) {
        print(fn)
//        fn(1, "2")
        fn(args[0] as! Int, args[1] as! String)
    }
}



// USER CODE
register("action") { (a: Int, b: String)  in
    print("Handler Called!")
}

invoke("action", args: [1, "2"])


import Riffle

/*
Because arbiter is broken at the time of this writing, receiver.swift and client.swift 
manually implemenmt a test suite for now. 

Tests (Success):
    Publish
    Subscribe
    Register
    Call

    Primitive Types
    Arrays
    Dictionaries
    Model Objects

    Errors on Connection
*/


class Dog: Model {
    var name = "Fido"
    var age = 43
}

class Receiver: Riffle.Domain, Riffle.Delegate {

    override func onJoin() {
        // print("Receiver joined!")

        subscribe("noargsSubscribe") { 
            print("Publish success")
        }

        register("noargsRegister") {
            return
        }

        register("intRegsiter") { (a: Int) in 
            assert(a == 1)
            return
        }

        // Example Pub/Sub Basic - This is a basic version of a pub/sub
        // subscribe("sub") { (a: Int, b: [String], c: Dog) in
        //     print("Received publish: \(a), with list: \(b), and pup: \(c.description)")
        // }.then {
        //     print("Subscription succeeded")
        // }.error { reason in
        //     print("An error occured", reason)
        // }
        // End Example Pub/Sub Basic

        // Example Reg/Call Basic 1 - This is a basic reg/call
        // register("basicReg") { (args: String) -> String in
        //     print("\(args)") // Expects a String, like "Hello"
        //     return "Hello World"
        // }.then {
        //     self.subscribe("pubby") {
        //         print("Receiver-Sender publish received")
        //     }
        // }
        // End Example Reg/Call Basic 1
    }
    
    override func onLeave() {
        print("Receiver left!")
    }
}


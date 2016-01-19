
import Riffle

class Dog: Model {
    var name = "Fido"
    var age = 43
}

class Receiver: Riffle.Domain, Riffle.Delegate {

    override func onJoin() {
        print("Receiver joined!")
        
        // register("reg") { (first: String, second: String) -> String in
        //     print("Received call! Args: ", first, second)
        //     return "Receiver says hi!"
        // }.then {
        //     print("Registration succeeded")
        // }.error { reason in
        //     print("An error occured", reason)
        // }
        
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
        register("basicReg") { (args: String) -> String in
            print("\(args)") // Expects a String, like "Hello"
            return "Hello World"
        }.then {
            sender.subscribe("pubby") {
                print("Receiver-Sender publish received")
            }
        }
        // End Example Reg/Call Basic 1
    }
    
    override func onLeave() {
        print("Receiver left!")
    }
}


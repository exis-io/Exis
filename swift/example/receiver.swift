import Riffle

class Dog: Model {
    var name = "Fido"
    var age = 43
}

class Receiver: Riffle.Domain, Riffle.Delegate {

    override func onJoin() {
        print("Receiver joined!")
        
        register("reg") { (first: String, second: String) -> String in
            print("Received call! Args: ", first, second)
            return "Receiver says hi!"
        }.then {
            print("Registration succeeded")
        }.error { reason in
            print("An error occured", reason)
        }
        
        subscribe("sub") { (a: Int, b: [String], c: Dog) in
            print("Received publish: \(a), with list: \(b), and pup: \(c.description)")
        }.then {
            print("Subscription succeeded")
        }.error { reason in
            print("An error occured", reason)
        }


        // register("reg") { (args: Any) -> Any? in
        //     print("Received call! Args: \(args)")
        //     return nil
        // }
        
        // // Example Pub/Sub Basic - This is a basic version of a pub/sub
        // subscribe("sub") { (args: Any) in       // Expects an Any, like "Hello"
        //     print("Received publish! \(args)")
        // }
        // // End Example Pub/Sub Basic
    }
    
    override func onLeave() {
        print("Receiver left!")
    }
}

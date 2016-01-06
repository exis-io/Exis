import Riffle

class Receiver: Riffle.Domain, Riffle.Delegate {

    override func onJoin() {
        print("Receiver joined!")

        // Example Pub/Sub Basic - This is a basic version of a pub/sub
        subscribe("basicSub") { (args: Any) in       // Expects a String, like "Hello"
            print("\(args)")
        }
        // End Example Pub/Sub Basic

        // Example Reg/Call Basic 1 - This is a basic reg/call
        register("basicReg") { (args: Any) -> Any? in
            print("\(args)") // Expects a String, like "Hello"
            return "Hello World"
        }
        // End Example Reg/Call Basic 1
    }
    
    override func onLeave() {
        print("Receiver left!")
    }
}

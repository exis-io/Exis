import Riffle

class Receiver: Riffle.Domain, Riffle.Delegate {

    override func onJoin() {
        print("Receiver joined!")

        // Example Pub/Sub Basic - This is a basic version of a pub/sub
        subscribe("basicSub") { (args: Any) in       // Expects a String, like "Hello"
            print("\(args)")
        }
        // End Example Pub/Sub Basic
    }
    
    override func onLeave() {
        print("Receiver left!")
    }
}



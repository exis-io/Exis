import riffle

class Receiver: riffle.Domain, riffle.Delegate {

    override func onJoin() {
        print("Receiver joined!")
        
        register("reg") { (args: Any) -> Any? in
            print("Received call! Args: \(args)")
            return nil
        }
        

        // Example Pub/Sub Basic - This is a basic version of a pub/sub
        subscribe("sub") { (args: Any) in       // Expects an Any, like "Hello"
            print("Received publish! \(args)")
        }
        // End Example Pub/Sub Basic
    }
    
    override func onLeave() {
        print("Receiver left!")
    }
}




import riffle

riffle.SetLogLevelDebug()
riffle.SetFabricLocal()


class Receiver: riffle.Domain, riffle.Delegate {

    override func onJoin() {
        print("Receiver joined!")
        
        register("reg") { (args: Any) -> Any? in
            print("Received call! Args: \(args)")
            return nil
        }
        

        subscribe("sub") { (args: Any) in
            print("Received publish! \(args)")
        }
    }
    
    override func onLeave() {
        print("Receiver left!")
    }
}

class Sender: riffle.Domain, riffle.Delegate  {
    
    override func onJoin() {
        print("Sender joined")

        publish("xs.damouse.alpha/sub", 1, "2", true)
        
        call("xs.damouse.alpha/reg", "Johnathan", "Seed") { returnArgs in
            print("Call received result \(returnArgs)")
        }
    }
    
    override func onLeave() {
        print("Sender left")
    }
}


if let result = NSProcessInfo.processInfo().environment["RECEIVER"] {
    print("Starting Receiver")
    let receiver = Receiver(name: "xs.damouse")
    receiver.delegate = receiver
    receiver.join()
} else {
    print("Starting Sender")
    Sender(name: "xs.damouse.beta").join()
    let sender = Sender(name: "xs.damouse")
    sender.delegate = sender
    sender.join()
}



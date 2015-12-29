// Testing

import Foundation

SetLogLevelDebug()
SetFabricLocal()


class Sender: Domain {
    
    override func onJoin() {
        publish("xs.damouse.alpha/sub", 1, "2", true)
        
        call("xs.damouse.alpha/reg", "Johnathan", "Seed") { returnArgs in
            print("Call received result \(returnArgs)")
        }
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}


class Receiver: Domain {
    
    override func onJoin() {
        register("reg") { (args: Any) -> Any? in
            print("Received call! Args: \(args)")
            return "Receiver says hi!"
        }
        
        subscribe("sub") { (args: Any) in
            print("Received publish! \(args)")
        }
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

//Receiver(name: "xs.damouse.alpha").join()

// Start the scripts
if let result = NSProcessInfo.processInfo().environment["RECEIVER"] {
    print("Starting Receiver")
    Receiver(name: "xs.damouse.alpha").join()
} else {
    print("Starting Sender")
    Sender(name: "xs.damouse.beta").join()
}

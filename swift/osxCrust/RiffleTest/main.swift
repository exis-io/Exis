// Testing

import Foundation

SetLogLevelDebug()
SetFabricLocal()


class Sender: Domain {
    
    override func onJoin() {
        
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}


class Receiver: Domain {
    
    override func onJoin() {
        register("reg") { (args: Any) -> Any? in
            print("Received call! Args: \(args)")
            return nil
        }
        
        subscribe("sub") { (args: Any) in
            print("Received publish! \(args)")
        }
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

// Start the scripts
if let result = NSProcessInfo.processInfo().environment["SENDER"] {
    print("Starting Sender")
    Sender(name: "xs.damouse.beta").join()
} else {
    print("Starting Receiver")
    Receiver(name: "xs.damouse.alpha").join()
}

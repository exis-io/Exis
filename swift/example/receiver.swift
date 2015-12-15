
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


let receiver = Receiver(name: "xs.damouse.alpha")
receiver.delegate = receiver
receiver.join()

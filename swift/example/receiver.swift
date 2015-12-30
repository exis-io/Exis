<<<<<<< HEAD

import riffle

riffle.SetLogLevelDebug()
riffle.SetFabricLocal()

riffle.ApplicationLog("Hello!")

class Receiver: riffle.Domain, riffle.Delegate {
=======
import Riffle

class Receiver: Riffle.Domain, Riffle.Delegate {
>>>>>>> f2e18e49bf8dd889f4359ce8faa5a92a3f4d6426

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


<<<<<<< HEAD
let receiver = Receiver(name: "xs.damouse.alpha")
receiver.delegate = receiver
receiver.join()
=======
>>>>>>> f2e18e49bf8dd889f4359ce8faa5a92a3f4d6426

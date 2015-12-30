<<<<<<< HEAD

import riffle

riffle.SetLogLevelDebug()
riffle.SetFabricLocal()

class Sender: riffle.Domain, riffle.Delegate  {
=======
import Riffle

class Sender: Riffle.Domain, Riffle.Delegate  {
>>>>>>> f2e18e49bf8dd889f4359ce8faa5a92a3f4d6426
    
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

<<<<<<< HEAD
let sender = Sender(name: "xs.damouse.beta")
sender.delegate = sender
sender.join()

=======
>>>>>>> f2e18e49bf8dd889f4359ce8faa5a92a3f4d6426

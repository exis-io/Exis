import Riffle

class Sender: Riffle.Domain, Riffle.Delegate  {
    
    override func onJoin() {
        print("Sender joined")

        // Create an object
        let dog = Dog()
        dog.name = "Billiam"
        dog.age = 88
        
        // Publish the object and assorted other arguments
        publish("xs.damouse.alpha/sub", 1, ["Hey", "There"], dog).then {
            print("Publish succeeded")
        }.error { reason in
            print("An error occured", reason)
        }
        
        // Call with assorted arguments, stipulating the resulting return types
        call("xs.damouse.alpha/reg", "Johnathan", "Seed").then { (a: String) in
            print("Call received: ", a)
        }

        // // Example Pub/Sub Basic - This is a basic version of a pub/sub
        // publish("xs.damouse.alpha/sub", 1, "2", true)
        // // End Example Pub/Sub Basic
        
        // call("xs.damouse.alpha/reg", "Johnathan", "Seed") { returnArgs in
        //     print("Call received result \(returnArgs)")
        // }
    }
    
    override func onLeave() {
        print("Sender left")
    }
}
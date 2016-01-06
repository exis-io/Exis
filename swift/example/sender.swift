import Riffle

class Sender: Riffle.Domain, Riffle.Delegate  {
    
    override func onJoin() {
        print("Sender joined")

        // Example Pub/Sub Basic - This is a basic version of a pub/sub
        let dog = Dog()
        dog.name = "Billiam"
        dog.age = 88

        publish("xs.damouse.alpha/sub", 1, ["Hey", "There"], dog).then {
            print("Publish succeeded")
        }.error { reason in
            print("An error occured", reason)
        }
        // End Example Pub/Sub Basic
        
        call("xs.damouse.alpha/reg", "Johnathan", "Seed").then { (a: String) in
            print("Call received: ", a)
        }
    }
    
    override func onLeave() {
        print("Sender left")
    }
}
import riffle

class Sender: riffle.Domain, riffle.Delegate  {
    
    override func onJoin() {
        print("Sender joined")

        // Example Pub/Sub Basic - This is a basic version of a pub/sub
        publish("xs.damouse.alpha/sub", 1, "2", true)
        // End Example Pub/Sub Basic
        
        call("xs.damouse.alpha/reg", "Johnathan", "Seed") { returnArgs in
            print("Call received result \(returnArgs)")
        }
    }
    
    override func onLeave() {
        print("Sender left")
    }
}


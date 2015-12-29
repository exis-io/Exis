import riffle

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


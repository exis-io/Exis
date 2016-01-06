import Riffle

class Sender: Riffle.Domain, Riffle.Delegate  {
    
    override func onJoin() {
        print("Sender joined")

        // Example Pub/Sub Basic - This is a basic version of a pub/sub
        publish("xs.demo.test.example/basicSub", "Hello")
        // End Example Pub/Sub Basic
        
        // Example Reg/Call Basic 1 - This is a basic reg/call
        call("xs.demo.test.example/basicReg", "Hello") { args in
            print("\(args)") // Expects a String, like "Hello World"
        }
        // End Example Reg/Call Basic 1
    }
    
    override func onLeave() {
        print("Sender left")
    }
}

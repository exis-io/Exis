import Riffle

class Sender: Riffle.Domain, Riffle.Delegate  {
    
    override func onJoin() {
        print("Sender joined")

        // Example Pub/Sub Basic - This is a basic version of a pub/sub
        publish("xs.demo.test.alpha/basicSub", "Hello")
        // End Example Pub/Sub Basic
    }
    
    override func onLeave() {
        print("Sender left")
    }
}
import Riffle

class TourBasics: Riffle.Domain, Riffle.Delegate {

    override func onJoin() {
        // Example Tour Basics 1 - simple print
        // ARBITER set action simple
        print("Hello World")
        // End Example Tour Basics 1
    
        // Example Tour Basics 2 - async NOTE this code won't run since pub/sub is in line
        subscribe("async") { (i: Int) in
            print("\(i)")
        }
        // End Example Tour Basics 2
        
        // Example Tour Basics 2 - async NOTE this code won't run since pub/sub is in line
        for i in 0...10 {
            publish("async", i)
        }
        // End Example Tour Basics 2
    
        print("___SETUPCOMPLETE___")
    }
    
    override func onLeave() {
        print("Receiver left!")
    }
}

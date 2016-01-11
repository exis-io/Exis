import Riffle

class TourRegBackend: Riffle.Domain, Riffle.Delegate {

    override func onJoin() {
        // Example Tour Reg/Call Lesson 1 - our first basic example
        register("myFirstCall") { (s: String) -> String in
            print(s) // Expects a String, like "Hello"
            return "Hello World"
        }
        // End Example Tour Reg/Call Lesson 1

        // Example Tour Reg/Call Lesson 2 Works - type enforcement good
        register("iWantStrings") { (s: String) -> String in
            print(s) // Expects a String, like "Hi"
            return "Thanks for saying " + s
        }
        // End Example Tour Reg/Call Lesson 2 Works
            
        // Example Tour Reg/Call Lesson 2 Fails - type enforcement bad
        register("iWantInts") { (i: Int) -> String in
            print(i) // Expects an Int, like 42
            return "Thanks for sending int \(i)"
        }
        // End Example Tour Reg/Call Lesson 2 Fails
    
        print("___SETUPCOMPLETE___")
    }
    
    override func onLeave() {
        print("Receiver left!")
    }
}

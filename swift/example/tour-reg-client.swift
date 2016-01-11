import Riffle

class TourRegClient: Riffle.Domain, Riffle.Delegate  {
    
    override func onJoin() {
        // Example Tour Reg/Call Lesson 1 - our first basic example
        call("myFirstCall", "Hello").then { (s: String) in
            print(s) // Expects a String, like "Hello World"
        }
        // End Example Tour Reg/Call Lesson 1
        
        // Example Tour Reg/Call Lesson 2 Works - type enforcement good
        call("iWantStrings", "Hi").then { (s: String) in
            print(s) // Expects a String, like "Thanks for saying Hi"
        }
        // End Example Tour Reg/Call Lesson 2 Works
        
        // Example Tour Reg/Call Lesson 2 Fails - type enforcement bad
        call("iWantInts", "Hi").then { (s: String) in
            print(s) // Expects a String, like "Thanks for sending int 42"
        }
        // End Example Tour Reg/Call Lesson 2 Fails
        
        print("___SETUPCOMPLETE___")
    }
    
    override func onLeave() {
        print("Sender left")
    }
}

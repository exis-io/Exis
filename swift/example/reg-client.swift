import Riffle

class Client: Riffle.Domain, Riffle.Delegate  {
    
    override func onJoin() {
        // Example Reg/Call str str - Basic reg expects string, returns string
        call("regStrStr", "Hello").then { (s: String) in
            print(s) // Expects a String, like "Hello World"
        }
        // End Example Reg/Call str str
        
        // Example Reg/Call str int - Basic reg expects string, returns int
        call("regStrInt", "Hello").then { (i: Int) in
            print("\(i)") // Expects an Int, like 42
        }
        // End Example Reg/Call str int
        
        // Example Reg/Call int str - Basic reg expects int, returns str
        call("regIntStr", 42).then { (s: String) in
            print(s) // Expects a String, like "Hello World"
        }
        // End Example Reg/Call int str
    }
    
    override func onLeave() {
        print("Sender left")
    }
}

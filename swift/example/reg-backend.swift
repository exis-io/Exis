import Riffle

class Backend: Riffle.Domain, Riffle.Delegate {

    override func onJoin() {
        // Example Reg/Call str str - Basic reg expects string, returns string
        register("regStrStr") { (s: String) -> String in
            print(s) // Expects a String, like "Hello"
            return "Hello World"
        }
        // End Example Reg/Call str str
            
        // Example Reg/Call str int - Basic reg expects string, returns int
        register("regStrInt") { (s: String) -> Int in
            print(s) // Expects a String, like "Hello"
            return 42
        }
        // End Example Reg/Call str int
            
        // Example Reg/Call int str - Basic reg expects int, returns str
        register("regIntStr") { (i: Int) -> String in
            print("\(i)") // Expects a String, like "42"
            return "Hello World"
        }
        // End Example Reg/Call int str
    }
    
    override func onLeave() {
        print("Receiver left!")
    }
}

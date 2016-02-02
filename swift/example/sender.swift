
import Riffle

class Sender: Riffle.Domain, Riffle.Delegate  {
    
    override func onJoin() {
        // Pub Sub Success Cases

        /*
        // No args
        backend.publish("subscribeNothing")

        // Primitive Types
        backend.publish("subscribePrimitives", 1, 2.2, 3.3, "4", true)

        // Arrys of simple types 
        backend.publish("subscribeArays", [1, 2], [2.2, 3.3], [4.4, 5.5], ["6", "7"], [true, false])


        // Reg/Call Success Cases
        // No arguments
        backend.call("registerNothing").then { 
            assert(true)
        }

        // Primitive Types
        backend.call("registerPrimitives", 1, 2.2, 3.3, "4", true) { (a: Int, b: Float, c: Double, d: String) in
            assert(a == 1)
            assert(b == 2.2)
            assert(c == 3.3)
            assert(d == "4")
            assert(e == true)
        })
    
        // Collections of simple types
        backend.call("registerPrimitives", [1, 2], [2.2, 3.3], [4.4, 5.5], ["6", "7"], [true, false]).then { (a: [Int], b: [Float], c: [Double], d: [String], e: [Bool]) in
            assert(a == [1, 2])
            assert(b == [2.2, 3.3])
            assert(c == [4.4, 5.5])
            assert(d == ["6", "7"])
            assert(e == [true, false])
        })

        */

        /*
        // Example Pub/Sub Basic - This is a basic version of a pub/sub
        publish("xs.test.example/basicSub", "Hello")
        // End Example Pub/Sub Basic
        */
        
        /*
        // Example Reg/Call Basic 1 - This is a basic reg/call
        call("basicReg", "Hello").then { (a: String) in
            print(a) // Expects a String, like "Hello World"
        }
        // End Example Reg/Call Basic 1
        */
    }
    
    override func onLeave() {
        print("Sender left")
    }
}

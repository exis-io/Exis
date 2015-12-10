// Testing

import Foundation

SetLoggingLevel(3)

//let url = "ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws"
//let domain = "xs.damouse"

class TestingDomain: Domain {
    
    override func onJoin() {
        print("Subclass joined!")
        
        register("reg") { (args: Any) -> Any? in
            print("Received call! Args: \(args)")
            return nil
        }
        
        subscribe("sub") { (args: Any) in
            print("Received publish! \(args)")
        }
    }
    
    override func onLeave() {
        print("Subclass left!")
    }
}

TestingDomain(name: "xs.damouse").join()
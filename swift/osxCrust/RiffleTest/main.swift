// Testing

import Foundation

SetLoggingLevel(3)
let url = "ws://ec2-52-26-83-61.us-west-2.compute.amazonaws.com:8000/ws"
let domain = "xs.damouse"

class TestingDomain: Domain {
    
    override func onJoin() {
        print("Subclass joined!")
    }
}

TestingDomain(name: "xs.damouse").join()

import Foundation
import Riffle

Riffle.LogLevelDebug()
Riffle.FabricLocal()

// Set an environment variable to launch either the sender or the receiver
if NSProcessInfo.processInfo().environment["SENDER"] != nil {
    Sender(name: "xs.demo.test.example").join()
} else {
    Receiver(name: "xs.demo.test.example").join()
}



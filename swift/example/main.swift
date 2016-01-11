
import Foundation
import Riffle

Riffle.LogLevelDebug()
Riffle.FabricLocal()

// Set an environment variable to launch either the sender or the receiver
if NSProcessInfo.processInfo().environment["CLIENT"] != nil {
    Client(name: "xs.demo.test.backend").join()
} else {
    Backend(name: "xs.demo.test.backend").join()
}



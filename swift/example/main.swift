
import Foundation
import Riffle

Riffle.LogLevelDebug()
Riffle.FabricLocal()

if NSProcessInfo.processInfo().environment["MANUAL"] != nil {
    if NSProcessInfo.processInfo().environment["CLIENT"] != nil {
        Sender(name: "xs.demo.test.backend").join()
    } else {
        Receiver(name: "xs.demo.test.backend").join()
    }
} else {
    // Set an environment variable to launch either the sender or the receiver
    if NSProcessInfo.processInfo().environment["CLIENT"] != nil {
        TourRegClient(name: "xs.demo.test.backend").join()
    } else {
        TourRegBackend(name: "xs.demo.test.backend").join()
    }
}



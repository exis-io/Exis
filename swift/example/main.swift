
import Foundation
import Riffle

Riffle.LogLevelDebug()
Riffle.FabricLocal()

let app = Riffle.Domain(name: "xs.test")
let sender = Sender(name: "sender", superdomain: app)
let backend = Receiver(name: "receiver", superdomain: app)

// print(NSProcessInfo.processInfo().environment["MANUAL"])

if NSProcessInfo.processInfo().environment["MANUAL"] != nil {
    if NSProcessInfo.processInfo().environment["CLIENT"] != nil {
        sender.join()
    } else {
        backend.join()
    }
} else {
    // Set an environment variable to launch either the sender or the receiver
    if NSProcessInfo.processInfo().environment["CLIENT"] != nil {
        TourRegClient(name: "xs.demo.test.backend").join()
    } else {
        TourRegBackend(name: "xs.demo.test.backend").join()
    }
}

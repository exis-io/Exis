
import Foundation
import Riffle

Riffle.setLogLevelDebug()
Riffle.setFabricDev()

let app = Domain(name: "xs.test")
let sender = Client(name: "sender", superdomain: app)
let backend = Backend(name: "receiver", superdomain: app)


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

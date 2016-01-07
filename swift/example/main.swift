
import Foundation
import Riffle

Riffle.LogLevelDebug()
Riffle.FabricLocal()

// Set an environment variable to launch either the sender or the receiver
if NSProcessInfo.processInfo().environment["SENDER"] != nil {
    Sender(name: "xs.damouse.beta").join()
} else {
    Receiver(name: "xs.damouse.alpha").join()
}



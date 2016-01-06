
import Riffle

print("Starting example test")

Riffle.LogLevelInfo()
Riffle.FabricLocal()

Receiver(name: "xs.damouse.alpha").join()

Sender(name: "xs.damouse.beta").join()



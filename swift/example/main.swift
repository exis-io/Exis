
import riffle

print("Linux example starting")
riffle.SetLogLevelDebug()
riffle.SetFabricLocal()

let domain = riffle.Domain(name: "xs.damouse")

class TestingDomain: riffle.RiffleDelegate {
    

    init() {}

    func onJoin() {
        print("Subclass joined!")
        
        domain.register("reg") { (args: Any) -> Any? in
            print("Received call! Args: \(args)")
            return nil
        }
        

        domain.subscribe("sub") { (args: Any) in
            print("Received publish! \(args)")
        }
    }
    
    func onLeave() {
        print("Subclass left!")
    }
}

let delegate = TestingDomain()
domain.delegate = delegate
domain.join()
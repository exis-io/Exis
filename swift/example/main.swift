
import Foundation
import Riffle

Riffle.LogLevelDebug()
Riffle.FabricLocal()

let app = Riffle.Domain(name: "xs.test")
let sender = Sender(name: "sender", superdomain: app)
let receiver = Receiver(name: "receiver", superdomain: app)

// print(NSProcessInfo.processInfo().environment["MANUAL"])

if NSProcessInfo.processInfo().environment["MANUAL"] != nil {
    if NSProcessInfo.processInfo().environment["CLIENT"] != nil {
        sender.join()
    } else {
        receiver.join()
    }
} else {
    // Set an environment variable to launch either the sender or the receiver
    if NSProcessInfo.processInfo().environment["CLIENT"] != nil {
        TourRegClient(name: "xs.demo.test.backend").join()
    } else {
        TourRegBackend(name: "xs.demo.test.backend").join()
    }
}




// New Form 
let app = Riffle.AppDomain(name: "xs.test")
let receiver = Receiver(name: "receiver", superdomain: app)

app.join().then {
    app.listen() 
}.error {
    print("Please log in")

    let username = "someUsernameFromInput"
    let password = "somePasswordFromInput"

    app.login(username, password).then { myDomain in 
        let sender = Sender(myDomain, superdomain: app)
        app.listen()
    }
}






let conn = Riffle.AppDomain(name: "xs.test")
let receiver = Receiver(name: "receiver", superdomain: app)



app.join().then { myDomain
    let me = Sender(myDomain, superdomain: app)
    app.listen() 

}.error {
    print("Please log in")

    let username = "someUsernameFromInput"
    let password = "somePasswordFromInpu"

    app.login("sender", username, password).then { myDomain in 
        let sender = Sender(myDomain, superdomain: app)
        app.listen()
    }.error { reason in 
        print("reason: \(reason)") // Waiting on email...
    }

    app.register("sender", username, password).then { myDomain in 
        let sender = Sender(myDomain, superdomain: app)
        app.listen()
    }.error { reason in 
        print(reason) // Username taken, password too short
    }
}


let app = Riffle.AppDomain("xs.test")

app.join("thisiswhoiam").then {

    let bouncer = Riffle.Domain("xs.Bouncer", app)

    publish("xs.test.lance.hello", "Im connected")
}

print "Im joined!"


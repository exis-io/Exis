//
//  main.swift
//  Backend
//
//  Created by damouse on 11/7/15.


import Foundation
import Riffle
import Glibc
import Dispatch

print("Starting up the backend...")
Riffle.setFabricDev()
Riffle.setLogLevelDebug()

//This is your apps backend
//Change USERNAME to your username that you used to sign up with at my.exis.io
let app = Domain(name: "xs.demo.USERNAME.swifthelloworld")

class Backend: Domain {
    override func onJoin() {
        print("Backend set up - registering calls")

        //register call allows you to listen in on specific roles 
        //and will call upon sayHi when reached out to
        register("hello", sayHi)
    }

    //Called when pinged from user
    func sayHi(name: String) -> Any {
        print("\(name) says hello! Lets let him know Exis is here to help!")
        return "Hi, \(name)! Exis can hear you loud and clear!"
    }
}

//Your container
let container = Backend(name: "container", superdomain: app)

//Joining container with your token
//Copy from: Auth() -> Authorized Key Management -> 'container' key
container.setToken("")

container.join()

NSRunLoop.currentRunLoop().run()
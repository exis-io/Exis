//
//  main.swift
//  Backend
//
//  Created by damouse on 11/7/15.


import Foundation
import Riffle

print("Starting up the backend...")

//This is your apps backend
//Change X's to your username that you used to sign up with at my.exis.io
let app = RiffleDomain(domain: "xs.demo.XXXXXXXXXXXXXX.helloworldswift")

class ContainerAgent: RiffleDomain {
    override func onJoin() {
        print("Backend set up - registering calls")

        //register call allows you to listen in on specific roles 
        //and will call upon sayHi when reached out to
        register("hello", sayHi)

        print("Successfully registered 'hello'")
    }

    //Called when pinged from user
    func sayHi(name: String) -> AnyObject {
        print("\(name) says hello! Lets let him know Exis is here to help!")
        return "Hi, \(name)! Exis can hear you loud and clear!"
    }
}

//Your container
let container = ContainerAgent(name: "container", superdomain: app)

//Joining container with your token
//Copy from: Auth() -> Authorized Key Management -> 'container' key
container.join("XXXXXXXXXXXXXX")

NSRunLoop.currentRunLoop().run()
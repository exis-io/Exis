/*
// Example REPL Template - The REPL code
// ARBITER set action template
import Foundation
import Riffle

// This connects us to the sandbox fabric
Riffle.SetFabricSandbox()

class ExisBackend: Domain, Delegate  {
    
    // When the connection is established this function is called
    override func onJoin() {
        
        // Exis code goes here
    
    }
}

// Setup the domain here
ExisBackend(name: "xs.demo.test.backend").join()

// End Example REPL Template
*/

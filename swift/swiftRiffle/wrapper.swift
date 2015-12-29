/*
Wrapper for the C functions coming from mantle.h so they can all be used as one monolithic 
riffle package.
*/

import mantle

public func SetLogLevelDebug(){
    mantle.SetLogLevelDebug()
}

public func SetFabricLocal() {
    mantle.SetFabricLocal()
}



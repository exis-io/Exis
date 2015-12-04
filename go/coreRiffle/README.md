# Riffle Core

Makes up all the juicy bits of all the other libraries, because lets face it-- go is pretty awsome. 

Unfortunatly it also has to deal with the vagaries of each individual platform, so this library can be all over the map at times. Each language and platform is built a little differently and has different qualities.

1. **OSX**: built as a static library. Can't handle collections. Really doesn't like callbacks from Go -> Swift. 
2. **iOS**: built using **gomobile**, a tool that creates ready-to-consume frameworks for arm and x86. Doesn't do well inside a cocoapod. In contrast to OSX, deals fantastically well with type conversion, but also doesn't like calling into swift.
3. **Python**: built as a shared library. Can also be built with **gopy**, but then has to deal with typing issues the shared library doesn't. Doesn't always play well with the GIL and GC.
4. **JS**: seamless connections between the languages using **gopherjs**, but Javascript is the only language that can't use the same websocket implementation as the rest of the lot. 


## Interfaces

The top level package implements abstract features as well as messaging. Because the interfaces between the core and the individual languages are so different, each wrapper ends up being a little different. 

The core implements:

* Messaging logic
* Abstract connection management
* Domain object
* Cumin (automatic type validation)
* Serialization

On top of the core sit the `wrappers`, which glue the foreign languages to the core. The wrappers are also written in Go, but may each have very different interfaces based on the languages their glueing. Wrappers have to either expose or invoke the following, depending on the structure of control of the platform:

**Connection**: implement and manage the websocket connection

- Send: send binary data
- Receive: block on a message channel
- BlockMessage: wait for a message to arrive for a set amount of time, then time out
- Close: terminate the connection

**Delegate**: called when domains change states. Each domain has a delegate.

- Invoke: call up through the wrapper to a native code function; trigger a callback
- OnJoin: the domain joined the fabric. Doesn't always mean the connection has just opened
- OnLeave: the domain has left the fabric. Doesn't mean the connection has closed

**Persistence**: expose access to platform specific storage, most likely to save cryptographic keys

Each wrapper has a subpackage within the core directory.

**Honcho**: top dog of riffle. Manages all domains and actively receives messages from Connection.

- HandleString
- HandleBytes
- HandleMessage

Each wrapper has a subpackage within the core directory.
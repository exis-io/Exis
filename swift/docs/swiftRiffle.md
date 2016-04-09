# swiftRiffle (v0.0.1)
swiftRiffle is a Swift library that provides an API for connection and interaction with Exis.

## Objects

<dl>
<dt><a href="#Riffle">Riffle</a> : <code>object</code></dt>
<dd><p>Riffle is the client side Swift library for interacting with Exis</p>
</dd>
</dl>

## Functions

<dl>
<dt><a href="#Domain">Domain(name, [superdomain])</a> ⇒ <code><a href="#Domain">Domain</a></code></dt>
<dd><p>Returns a new Domain object on a new connection.</p>
</dd>
</dl>

<a name="Riffle"></a>

## Riffle : <code>object</code>
Riffle is the client side Swift library for interacting with Exis

**Kind**: global namespace  
**Example**  
```swift
//**Configuration Example**
import Riffle

//connect to production node
Riffle.setFabricProduction();

// Setup domain object
let d = Domain(name: "xs.domain.app")
```

* [Riffle](#Riffle) : <code>object</code>
    * [.setFabric(url)](#Riffle.setFabric)
    * [.setFabricLocal()](#Riffle.setFabricLocal)
    * [.setFabricProduction()](#Riffle.setFabricProduction)
    * [.setLogLevelApp()](#Riffle.setLogLevelApp)
    * [.setLogLevelOff()](#Riffle.setLogLevelOff)
    * [.setLogLevelErr()](#Riffle.setLogLevelErr)
    * [.setLogLevelWarn()](#Riffle.setLogLevelWarn)
    * [.setLogLevelInfo()](#Riffle.setLogLevelInfo)
    * [.setLogLevelDebug()](#Riffle.setLogLevelDebug)
    * [.application()](#Riffle.application)
    * [.info()](#Riffle.info)
    * [.debug()](#Riffle.debug)
    * [.warn()](#Riffle.warn)
    * [.error()](#Riffle.error)

<a name="Riffle.setFabric"></a>

### Riffle.setFabric(url)
Sets the url of the node being connected to.

**Kind**: static method of <code>[Riffle](#Riffle)</code>  

| Param | Type | Description |
| --- | --- | --- |
| url | <code>String</code> | The url of the node to be connected to. |

**Example**  
```swift
//connect to exis production node 
Riffle.setFabric('wss://node.exis.io:8000/ws');
```
<a name="Riffle.setFabricLocal"></a>

### Riffle.setFabricLocal()
Connect to a node running locally.

**Kind**: static method of <code>[Riffle](#Riffle)</code>  
<a name="Riffle.setFabricProduction"></a>

### Riffle.setFabricProduction()
Connect to node.exis.io, the Exis production node.

**Kind**: static method of <code>[Riffle](#Riffle)</code>  
<a name="Riffle.setLogLevelApp"></a>

### Riffle.setLogLevelApp()
Set log level to application

**Kind**: static method of <code>[Riffle](#Riffle)</code>  
<a name="Riffle.setLogLevelOff"></a>

### Riffle.setLogLevelOff()
Set log level to off

**Kind**: static method of <code>[Riffle](#Riffle)</code>  
<a name="Riffle.setLogLevelErr"></a>

### Riffle.setLogLevelErr()
Set log level to error

**Kind**: static method of <code>[Riffle](#Riffle)</code>  
<a name="Riffle.setLogLevelWarn"></a>

### Riffle.setLogLevelWarn()
Set log level to warning

**Kind**: static method of <code>[Riffle](#Riffle)</code>  
<a name="Riffle.setLogLevelInfo"></a>

### Riffle.setLogLevelInfo()
Set log level to info

**Kind**: static method of <code>[Riffle](#Riffle)</code>  
<a name="Riffle.setLogLevelDebug"></a>

### Riffle.setLogLevelDebug()
Set log level to debug

**Kind**: static method of <code>[Riffle](#Riffle)</code>  
<a name="Riffle.application"></a>

### Riffle.application()
Print an application level message

**Kind**: static method of <code>[Riffle](#Riffle)</code>  
<a name="Riffle.info"></a>

### Riffle.info()
Print an info level message

**Kind**: static method of <code>[Riffle](#Riffle)</code>  
<a name="Riffle.debug"></a>

### Riffle.debug()
Print a debug level message

**Kind**: static method of <code>[Riffle](#Riffle)</code>  
<a name="Riffle.warn"></a>

### Riffle.warn()
Print a warn level message

**Kind**: static method of <code>[Riffle](#Riffle)</code>  
<a name="Riffle.error"></a>

### Riffle.error()
Print an error level message

**Kind**: static method of <code>[Riffle](#Riffle)</code>  
<a name="Domain"></a>

## Domain(name, [superdomain]) ⇒ <code>[Domain](#Domain)</code>
Returns a new Domain object on a new connection.

**Kind**: global function  
**Returns**: <code>[Domain](#Domain)</code> - - A [Domain](#Domain) object  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>String</code> | The domain. |
| [superdomain] | <code>[Domain](#Domain)</code> | optional superdomain Domain object |

**Example**  
```swift
//sets app to app1 domain 
let app = Riffle.Domain('xs.demo.user.app1')
//Create a subdomain
let sub = Riffle.Domain('app1', app)
```

* [Domain(name, [superdomain])](#Domain) ⇒ <code>[Domain](#Domain)</code>
    * [.register(action, handler)](#Domain.register) ⇒ <code>Promise</code>
    * [.call(action, ...args)](#Domain.call) ⇒ <code>Promise</code>
    * [.publish(channel, ...args)](#Domain.publish)
    * [.subscribe(channel, handler)](#Domain.subscribe) ⇒ <code>Promise</code>
    * [.unsubscribe(channel)](#Domain.unsubscribe)
    * [.unregister(action)](#Domain.unregister)
    * [.join()](#Domain.join)
    * [.leave()](#Domain.leave)
    * [.login([user])](#Domain.login) ⇒ <code>[Domain](#Domain)</code>

<a name="Domain.register"></a>

### Domain.register(action, handler) ⇒ <code>Promise</code>
Register a function to handle calls made to action on this domain. If the domain object represents a domain like `xs.demo.user.app` the 
endpoint that the handler is registered to will look like `xs.demo.user.app/action`.

**Kind**: static method of <code>[Domain](#Domain)</code>  
**Returns**: <code>Promise</code> - a promise that is resolved if the handler is successfully registered or rejected if there is an error.  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>String</code> | The action that the handler should be registered as under the domain. |
| handler | <code>function</code> | The function that will handle any calls made to the registered endpoint or a valid [$riffle.want]($riffle.want) function. |

**Example**  
```swift
//**Registering a Procedure**
//register an action call hello on our top level app domain. i.e. xs.demo.user.app/hello
app.onJoin = {
  register("hello") { (s: String) -> String in
    print("hello")
  }
}
```
<a name="Domain.call"></a>

### Domain.call(action, ...args) ⇒ <code>Promise</code>
Call a function already registered to an action on this domain. If the domain object represents an domain like `xs.demo.user.app` the 
endpoint that is called to will look like `xs.demo.user.app/action`.

**Kind**: static method of <code>[Domain](#Domain)</code>  
**Returns**: <code>Promise</code> - Returns a promise  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>String</code> | The action the function being called is registered under on the domain. |
| ...args | <code>Any</code> | The arguments to provide to the function being called. |

**Example**  
```swift
//**Make a call**
//call an action sum on with two numbers on our top level app domain. i.e. xs.demo.user.app/sum
app.call("sum", 1).then { (s: String) in 
  print("sum returned \(s)")
}
```
<a name="Domain.publish"></a>

### Domain.publish(channel, ...args)
Publish data to any subscribers listening on a given channel on the domain. If the [domain](#Domain) represents a domain like `xs.demo.user.app` the 
endpoint that is published to will look like `xs.demo.user.app/channel`.

**Kind**: static method of <code>[Domain](#Domain)</code>  

| Param | Type | Description |
| --- | --- | --- |
| channel | <code>String</code> | The channel the being published to on the domain. |
| ...args | <code>Any</code> | The arguments to publish to the channel. |

**Example**  
```swift
//**Publishing**
//publish the string 'hello' to the `ping` channel on our top level app domain. i.e. `xs.demo.user.app/ping`
app.publish("ping", "hello")
```
<a name="Domain.subscribe"></a>

### Domain.subscribe(channel, handler) ⇒ <code>Promise</code>
Subscribe a function to handle publish events made to the channel on this domain. If the domain object represents an domain like `xs.demo.user.app` the 
endpoint that the handler is subscribed to will look like `xs.demo.user.app/channel`.

**Kind**: static method of <code>[Domain](#Domain)</code>  
**Returns**: <code>Promise</code> - a promise that is resolved if the handler is successfully subscribed or rejected if there is an error.  

| Param | Type | Description |
| --- | --- | --- |
| channel | <code>String</code> | The channel that the handler should subscribe to under the domain. |
| handler | <code>function</code> | The function that will handle any publishes made to the registered endpoint or a valid [jsRiffle.want](jsRiffle.want) function. |

**Example**  
```swift
//**Subscribing to an Event**
//subscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
app.subscribe("hello") { (s: String) in
  print("Received hello event!")
}
```
<a name="Domain.unsubscribe"></a>

### Domain.unsubscribe(channel)
Unsubscribe all handlers subscribe to the channel on this domain.

**Kind**: static method of <code>[Domain](#Domain)</code>  

| Param | Type | Description |
| --- | --- | --- |
| channel | <code>String</code> | The channel that you wish to unsubscribe handlers from under the domain. |

**Example**  
```swift
//**Unsubscribe**
//unsubscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
app.unsubscribe("hello")
```
<a name="Domain.unregister"></a>

### Domain.unregister(action)
Unregister the handler for the specified action on this domain.

**Kind**: static method of <code>[Domain](#Domain)</code>  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>String</code> | The action that you wish to unregister the handler from under the domain. |

**Example**  
```swift
//**Unregister**
//unregister the 'getData' action handler on our top level app domain. i.e. xs.demo.user.app/getData
app.unregister("getData")
```
<a name="Domain.join"></a>

### Domain.join()
Attempts to create a connection to the Exis fabric using this domain. If successful a the `app.onJoin` function will be called
to notify a successful connection was established.

**Kind**: static method of <code>[Domain](#Domain)</code>  
**Example**  
```swift
//**Joining a domain**

//if the join is successful this function will be triggered
class App: Domain {
  override func onJoin() {
    print("Connected!")
  }
}

let app = App(name: "xs.demo.user.app")
//attempt to join connect to Exis as the top level domain i.e. xs.demo.user.app
app.join()
```
<a name="Domain.leave"></a>

### Domain.leave()
Unregister and unsubscribe anything in the domain and disconnect from Exis if this the the domain that [join](#Domain.join) was called on.
If the connection is closed the `onLeave` will be called notifying that the session has been closed.

**Kind**: static method of <code>[Domain](#Domain)</code>  
**Example**  
```swift
//**Logout/Disconnect**

//if the connection is closed this function will be triggered
class App: Domain {
  override func onLeave() {
    print("Connection closed!")
  }
}

//unregister/unsubscribe any handlers on the top level domain and close the connection if it this the the domain join was called on.
app.leave()
```
<a name="Domain.login"></a>

### Domain.login([user]) ⇒ <code>[Domain](#Domain)</code>
Log the user in via the [Auth](/docs/appliances/Auth) appliance for this app and open the connection to Exis.
If the attached Auth appliance is level 1 then the user object must be provided. For level 0 you can call login with an empty object
to connect with at temporary random username. Passing in just the username will attempt to login the user with the given username
if it is available.

**Kind**: static method of <code>[Domain](#Domain)</code>  
**Returns**: <code>[Domain](#Domain)</code> - returns a promise object which is resolved upon success or rejected on failure.  

| Param | Type | Description |
| --- | --- | --- |
| [user] | <code>object</code> | An object containing the login info for the user. |
| user.username | <code>String</code> | The user's username as registered with Auth. |
| [user.password] | <code>String</code> | The user's password. |

**Example**  
```swift
//**Login Example**
app.login("sender", username, password).then { myName: String
  sender = Domain(myName, superdomain: app)
}.error { reason: String
  print("reason: \(reason)") // Waiting on email...
}
```

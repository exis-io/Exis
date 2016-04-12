
/**
 * @version 0.0.1
 */

/**
 * @namespace Riffle
 * @description Riffle is the client side Swift library for interacting with Exis
 * @example
 * //**Configuration Example**
 * import Riffle
 *
 * //connect to production node
 * Riffle.setFabricProduction();
 *
 * // Setup domain object
 * let d = Domain(name: "xs.domain.app")
 *
 */

/**
 * @memberof Riffle
 * @function setFabric
 * @param {String} url - The url of the node to be connected to.
 * @description Sets the url of the node being connected to.
 * @example 
 * //connect to exis production node 
 * Riffle.setFabric('wss://node.exis.io:8000/ws');
 */

/**
 * @memberof Riffle
 * @function setFabricLocal
 * @description Connect to a node running locally.
 */

/**
 * @memberof Riffle
 * @function setFabricProduction
 * @description Connect to node.exis.io, the Exis production node.
 */

/**
 * @memberof Riffle
 * @function setLogLevelApp
 * @description Set log level to application
 */

/**
 * @memberof Riffle
 * @function setLogLevelOff
 * @description Set log level to off
 */

/**
 * @memberof Riffle
 * @function setLogLevelErr
 * @description Set log level to error
 */

/**
 * @memberof Riffle
 * @function setLogLevelWarn
 * @description Set log level to warning
 */

/**
 * @memberof Riffle
 * @function setLogLevelInfo
 * @description Set log level to info
 */

/**
 * @memberof Riffle
 * @function setLogLevelDebug
 * @description Set log level to debug
 */

/**
 * @memberof Riffle
 * @function application
 * @description Print an application level message
 */

/**
 * @memberof Riffle
 * @function info
 * @description Print an info level message
 */

/**
 * @memberof Riffle
 * @function debug
 * @description Print a debug level message
 */

/**
 * @memberof Riffle
 * @function warn
 * @description Print a warn level message
 */

/**
 * @memberof Riffle
 * @function error
 * @description Print an error level message
 */

/**
 * @function Domain
 * @param {String} name The domain.
 * @param {Domain} [superdomain] optional superdomain Domain object
 * @returns {Domain} - A {@link Domain} object
 * @description Returns a new Domain object on a new connection.
 * @example 
 * //sets app to app1 domain 
 * let app = Riffle.Domain('xs.demo.user.app1')
 * //Create a subdomain
 * let sub = Riffle.Domain('app1', app)
 */

/**
 * @memberof Domain
 * @function register
 * @param {String} action - The action that the handler should be registered as under the domain.
 * @param {function} handler - The function that will handle any calls made to the registered endpoint or a valid {@link $riffle.want} function.
 * @description Register a function to handle calls made to action on this domain. If the domain object represents a domain like `xs.demo.user.app` the 
 * endpoint that the handler is registered to will look like `xs.demo.user.app/action`.
 * @returns {Promise} a promise that is resolved if the handler is successfully registered or rejected if there is an error.
 * @example
 * //**Registering a Procedure**
 * //register an action call hello on our top level app domain. i.e. xs.demo.user.app/hello
 * app.onJoin = {
 *   register("hello") { (s: String) -> String in
 *     print("hello")
 *   }
 * }
 */

/**
 * @memberof Domain
 * @function call
 * @param {String} action - The action the function being called is registered under on the domain.
 * @param {...Any} args - The arguments to provide to the function being called.
 * @description Call a function already registered to an action on this domain. If the domain object represents an domain like `xs.demo.user.app` the 
 * endpoint that is called to will look like `xs.demo.user.app/action`.
 * @returns {Promise} Returns a promise
 * @example
 * //**Make a call**
 * //call an action sum on with two numbers on our top level app domain. i.e. xs.demo.user.app/sum
 * app.call("sum", 1).then { (s: String) in 
 *   print("sum returned \(s)")
 * }
 */

/**
 * @memberof Domain
 * @function publish
 * @param {String} channel - The channel the being published to on the domain.
 * @param {...Any} args - The arguments to publish to the channel.
 * @description Publish data to any subscribers listening on a given channel on the domain. If the {@link Domain domain} represents a domain like `xs.demo.user.app` the 
 * endpoint that is published to will look like `xs.demo.user.app/channel`.
 * @example
 * //**Publishing**
 * //publish the string 'hello' to the `ping` channel on our top level app domain. i.e. `xs.demo.user.app/ping`
 * app.publish("ping", "hello")
 */

/**
 * @memberof Domain
 * @function subscribe
 * @param {String} channel - The channel that the handler should subscribe to under the domain.
 * @param {function} handler - The function that will handle any publishes made to the registered endpoint or a valid {@link jsRiffle.want} function.
 * @description Subscribe a function to handle publish events made to the channel on this domain. If the domain object represents an domain like `xs.demo.user.app` the 
 * endpoint that the handler is subscribed to will look like `xs.demo.user.app/channel`.
 * @returns {Promise} a promise that is resolved if the handler is successfully subscribed or rejected if there is an error.
 * @example
 * //**Subscribing to an Event**
 * //subscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
 * app.subscribe("hello") { (s: String) in
 *   print("Received hello event!")
 * }
 */

/**
 * @memberof Domain
 * @function unsubscribe
 * @param {String} channel - The channel that you wish to unsubscribe handlers from under the domain.
 * @description Unsubscribe all handlers subscribe to the channel on this domain. 
 * @example
 * //**Unsubscribe**
 * //unsubscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
 * app.unsubscribe("hello")
 */

/**
 * @memberof Domain
 * @function unregister
 * @param {String} action - The action that you wish to unregister the handler from under the domain.
 * @description Unregister the handler for the specified action on this domain. 
 * @example
 * //**Unregister**
 * //unregister the 'getData' action handler on our top level app domain. i.e. xs.demo.user.app/getData
 * app.unregister("getData")
 */

/**
 * @memberof Domain
 * @function join
 * @description Attempts to create a connection to the Exis fabric using this domain. If successful a the `app.onJoin` function will be called
 * to notify a successful connection was established.
 * @example
 * //**Joining a domain**
 *
 * //if the join is successful this function will be triggered
 * class App: Domain {
 *   override func onJoin() {
 *     print("Connected!")
 *   }
 * }
 * 
 * let app = App(name: "xs.demo.user.app")
 * //attempt to join connect to Exis as the top level domain i.e. xs.demo.user.app
 * app.join()
 */

/**
 * @memberof Domain
 * @function leave
 * @description Unregister and unsubscribe anything in the domain and disconnect from Exis if this the the domain that {@link Domain.join} was called on.
 * If the connection is closed the `onLeave` will be called notifying that the session has been closed.
 * @example
 * //**Logout/Disconnect**
 *
 * //if the connection is closed this function will be triggered
 * class App: Domain {
 *   override func onLeave() {
 *     print("Connection closed!")
 *   }
 * }
 *
 * //unregister/unsubscribe any handlers on the top level domain and close the connection if it this the the domain join was called on.
 * app.leave()
 */

/**
 * @memberof Domain
 * @function login
 * @param {object=} user - An object containing the login info for the user.
 * @param {String} user.username - The user's username as registered with Auth.
 * @param {String=} user.password - The user's password.
 * @description Log the user in via the {@link /docs/appliances/Auth Auth} appliance for this app and open the connection to Exis.
 * If the attached Auth appliance is level 1 then the user object must be provided. For level 0 you can call login with an empty object
 * to connect with at temporary random username. Passing in just the username will attempt to login the user with the given username
 * if it is available.
 * @returns {Domain} returns a promise object which is resolved upon success or rejected on failure.
 * @example 
 * //**Login Example**
 * app.login("sender", username, password).then { myName: String
 *   sender = Domain(myName, superdomain: app)
 * }.error { reason: String
 *   print("reason: \(reason)") // Waiting on email...
 * }
 */


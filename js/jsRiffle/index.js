///////////////////////////////////////////////////////////////////////////////
//
//  jsRiffle - http://exis.io, 
//
//
///////////////////////////////////////////////////////////////////////////////

global.WsFactory = require('./src/node/websocket').Factory;
global.xsOverHTTP = require('./src/node/xsNodeHttp')
module.exports = require('./src/riffle');
 
/**
 * @version 0.4.8
 */

/**
 * @namespace jsRiffle
 * @description jsRiffle is the client side JavaScript library for interacting with Exis
 * @example
 * //**Configuration Example**
 * //via Node.js
 * jsRiffle = require('jsriffle');
 * jsRiffle.Domain('xs.domain');
 *
 * //access globally in browser
 * jsRiffle.Domain('xs.domain');
 *
 * //connect to production node
 * jsRiffle.setFabricProduction();
 */

/**
 * @memberof jsRiffle
 * @function setFabric
 * @param {string} url - The url of the node to be connected to.
 * @description Sets the url of the node being connected to.
 * @example 
 * //connect to exis sandbox node 
 * jsRiffle.setFabric('ws://sandbox.exis.io:8000/ws');
 */

/**
 * @memberof jsRiffle
 * @function setFabricLocal
 * @description Connect to a node running locally.
 */

/**
 * @memberof jsRiffle
 * @function setFabricProduction
 * @description Connect to node.exis.io, the Exis production node.
 */

/**
 * @memberof jsRiffle
 * @function setFabricSandbox
 * @description Connect to sandbox.exis.io, the Exis sandbox node.
 */

/**
 * @memberof jsRiffle
 * @function Domain
 * @param {string} domain - The domain.
 * @returns {Domain} - A {@link Domain} object
 * @description Returns a new Domain object on a new connection.
 * @example 
 * //sets app to app1 domain 
 * var app = jsRiffle.Domain('xs.demo.user.app1');
 */

/**
 * @memberof jsRiffle
 * @function modelObject
 * @param {RiffleConstructor} class - A valid {@link RiffleConstructor}
 * @description Creates a new modelObject class using the given properly formed {@link RiffleConstructor}.
 * @returns {ModelObject} A new ModelObject that can be used for interacting with Model Object Storage and the
 * {@link jsRiffle.want} syntax.
 * @example
 * //create a custom Person class
 * function Person(){
 *   this.first = String;
 *   this.last = String;
 *   this.age = Number;
 * }
 *
 * Person.prototype.fullname = function(){
 *   return this.first + ' ' + this.last;
 * }
 * //create a ModelObect class representing our Person class
 * var person = jsRiffle.modelObject(Person);
 */

/**
 * @memberof jsRiffle
 * @function want
 * @param {function} handler - A function that handles the call/publish events.
 * @param {...Type} types - A list of the Types the handler expects as arguments. Valid types are `String`, `Number`, `[Type]`(an Array with elements of `Type`),
 * `{key1: Type, key2: Type}`(An object with keys `key1` and `key2` each of `Type`), or `ModelObject`(a valid {@link ModelObject}). 
 * @description Takes the handler and the expected types that the subscribe or register handler expects and ensures
 * that the handler is only called if the data is correctly formatted. If the type wanted is a {@link ModelObject}
 * then the data is constructed to be of the proper {@link ModelObject} class.
 * @see {@link RifflePromise.want here} for information about wants and expecting returns from {@link RiffleDomain.call calls}.
 * @returns {function} A new function which can be passed in as the handler of a {@link subscribe} or {@link register} call
 * to ensure the handlers are only called if the data is properly formatted. 
 * @example
 * //create a custom Person class
 * function Person(){
 *   this.first = String;
 *   this.last = String;
 *   this.age = Number;
 * }
 *
 * Person.prototype.fullname = function(){
 *   return this.first + ' ' + this.last;
 * }
 * //create a ModelObect class representing our Person class
 * var person = jsRiffle.modelObject(Person);
 *
 * //register a function that accepts only a Number and a Person
 * //The caller will receive an error if the arguments aren't correct
 * //expects call that looks like app.call('isOlder', 18, {first: 'John', last: 'Doe', age: 21});
 * app.register('isOlder', jsRiffle.want(function(age, person){
 *   if(person.age > age){
 *     console.log(person.fullname + 'is older than ' + age);
 *   }
 * }, Number, person));
 *
 */


/**
 * @typedef ModelObject
 * @description The ModelObject class is used to to wrap a custom JavaScript class and provides an API for interaction with
 * Model Object Storage via a {@link /docs/appliances/Storage Storage} appliance. It can also be provided as an argument to
 * {@link jsRiffle.want} to ensure objects recieved have the correct properties 
 * and are constructed with the correct prototype.
 * @example
 * //create a custom Person class
 * function Person(){
 *   this.first = String;
 *   this.last = String;
 *   this.age = Number;
 * }
 *
 * Person.prototype.fullname = function(){
 *   return this.first + ' ' + this.last;
 * }
 * //create a ModelObect class representing our Person class
 * var person = jsRiffle.modelObject(Person);
 */

/**
 * @memberof ModelObject
 * @function bind
 * @param {RiffleDomain} domain - A {@link RiffleDomain} object representing the attached {@link /docs/appliances/Storage Storage} appliance
 * or a domain currently connected to Exis.
 * @param {string=} storage - The fully qualified domain of the {@link /docs/appliances/Storage Storage} appliance which to bind this ModelObject collection.
 * If none is provided the `domain` object is assumed to be the {@link /docs/appliances/Storage Storage} appliance.
 * @param {string=} collection - The name of the collection to bind the instance to. If none is provide the name of the class passed to {@link jsRiffle.modelObject} is used.
 * @description Bind this instance of the ModelObject with a collection of ModelObjects in a {@link /docs/appliances/Storage Storage} appliance.
 * Any instances constructed from the orignal {@link RiffleConstructor} or that are created as the result of either a
 * {@link jsRiffle.want want[reg/sub]} or a {@link RifflePromise.want want[call]} will have the {@link ModelObject#save} and {@link ModelObject#delete} functions attached to the instance.
 * @example
 * //create a custom Person class
 * function Person(){
 *   this.first = String;
 *   this.last = String;
 *   this.age = Number;
 * }
 *
 * Person.prototype.fullname = function(){
 *   return this.first + ' ' + this.last;
 * }
 * //create a ModelObect class representing our Person class
 * var person = jsRiffle.modelObject(Person);
 *
 * //create a subdomain representing a Storage applinance
 * var storage = app.subdomain('Storage');
 *
 * //bind the person ModelObject to the Storage appliance
 * person.bind(storage); //The collection will be named Person based on the class by default
 */

/**
 * @memberof ModelObject
 * @function find
 * @param {object} query - A valid MongoDB {@link https://docs.mongodb.org/manual/tutorial/query-documents/ query} object.
 * @description Query the ModelObject collection in the bound {@link /docs/appliances/Storage Storage} appliance for multiple documents matching the query.
 * @returns {Promise} A promise which will be resovled with the matching objects on success or rejected on error.
 * @throws An error if the {@link ModelObject} class isn't bound to a {@link /docs/appliances/Storage Storage} appliance.
 * @example
 * //create a custom Person class
 * function Person(){
 *   this.first = String;
 *   this.last = String;
 *   this.age = Number;
 * }
 *
 * Person.prototype.fullname = function(){
 *   return this.first + ' ' + this.last;
 * }
 * //create a ModelObect class representing our Person class
 * var person = jsRiffle.modelObject(Person);
 *
 * //create a subdomain representing a Storage applinance
 * var storage = app.subdomain('Storage');
 *
 * //bind the person ModelObject to the Storage appliance
 * person.bind(storage); //The collection will be named Person based on the class by default
 *
 * //query for all users named Nick
 * person.find({first: 'Nick'}).then(handleNicks);
 */

/**
 * @memberof ModelObject
 * @function find_one
 * @param {object} query - A valid MongoDB {@link https://docs.mongodb.org/manual/tutorial/query-documents/ query} object.
 * @description Query the ModelObject collection in the bound {@link /docs/appliances/Storage Storage} appliance for the first document matching the query.
 * @returns {Promise} A promise which will be resovled with the matching object on success or rejected on error.
 * @throws An error if the {@link ModelObject} class isn't bound to a {@link /docs/appliances/Storage Storage} appliance.
 * @example
 * //create a custom Person class
 * function Person(){
 *   this.first = String;
 *   this.last = String;
 *   this.age = Number;
 * }
 *
 * Person.prototype.fullname = function(){
 *   return this.first + ' ' + this.last;
 * }
 * //create a ModelObect class representing our Person class
 * var person = jsRiffle.modelObject(Person);
 *
 * //create a subdomain representing a Storage applinance
 * var storage = app.subdomain('Storage');
 *
 * //bind the person ModelObject to the Storage appliance
 * person.bind(storage); //The collection will be named Person based on the class by default
 *
 * //query for the first user named Nick
 * person.find_one({first: 'Nick'}).then(handleNick);
 */

/**
 * @memberof ModelObject
 * @function save
 * @instance
 * @description Save the instance of the {@link ModelObject} to the collection and {@link /docs/appliances/Storage Storage} appliance it is bound to.
 * @returns {Promise} A promise that is resolved on success or rejected if there is an error.
 * @throws An error if the parent {@link ModelObject} class isn't bound to a {@link /docs/appliances/Storage Storage} appliance.
 * @example
 * //query for the first user named Nick Hyatt based on the person ModelObject created in the above example
 * person.find_one({first: 'Nick', last: 'Hyatt'}).then(function(nick){
 *   console.log(nick.fullname()); //prints 'Nick Hyatt'
 *   //change Nick's name to Steve
 *   nick.first = 'Steve';
 *   console.log(nick.fullname()); //prints 'Steve Hyatt'
 *   nick.save(); //Overwrites the old document 
 * });
 */

/**
 * @memberof ModelObject
 * @function delete
 * @instance
 * @description Delete the instance of  the {@link ModelObject} from the collection and {@link /docs/appliances/Storage Storage} appliance it is bound to.
 * @returns {Promise} A promise that is resolved on success or rejected if there is an error.
 * @throws An error if the parent {@link ModelObject} class isn't bound to a {@link /docs/appliances/Storage Storage} appliance.
 * @example
 * //query for the first user named Nick Hyatt based on the person ModelObject created in the above example
 * person.find_one({first: 'Nick', last: 'Hyatt'}).then(function(nick){
 *   nick.delete(); //removes document from storage
 * });
 */

/**
 * @typedef RiffleConstructor
 * @description A RiffleConstructor is simply a class constructor function with the expected property set to be the expected `Type`
 * This Constructor can be used to create a {@link ModelObject} via the {@link jsRiffle.modelObject} function and used for as an expected
 * type for {@link jsRiffle.want}.
 * @example
 * //A valid RiffleConstructor for the Person class with attached prototype
 * function Person(){
 *   this.first = String;
 *   this.last = String;
 *   this.age = Number;
 * }
 *
 * Person.prototype.fullname = function(){
 *   return this.first + ' ' + this.last;
 * }
 */


/**
 * @typedef RiffleDomain
 * @description A RiffleDomain is an object which represents a specific {@link /docs/riffle/Domain domain} on Exis and
 * provides an API for performing actions such as {@link RiffleDomain.register} and {@link RiffleDomain.call} on behalf of the {@link /docs/riffle/Domain domain}.
 * The {@link jsRiffle.Domain} function returns a domain on a new connection using the string provided i.e. `xs.demo.user.app`. Creating subdomains from the {@link RiffleDomain}
 * would give us domain objects representing a domain like `xs.demo.user.app.subdomain`. Creating subdomains from any `RiffleDomain` always creates a new domain object
 * with its namespace one level lower than it's parent.
 * @example
 * //create a valid domain
 * var app = jsRiffle.Domain('xs.demo.dev.app');
 * //construct a valid subdomain from app domain
 * var backend = app.subdomain('backend');
 *
 * //call a function that our backend domain has registered as part of its API
 * backend.call('getData').then(handler);
 */

/**
 * @memberof RiffleDomain
 * @function getName
 * @description Get the string representation of the domain.
 * @returns {string} The string representation of the domain. i.e. `xs.demo.user.app`.
 * @example
 * app.getName(); //returns 'xs.demo.developer.app'
 */

/**
 * @memberof RiffleDomain
 * @function register
 * @param {string} action - The action that the handler should be registered as under the domain.
 * @param {function} handler - The function that will handle any calls made to the registered endpoint or a valid {@link $riffle.want} function.
 * @description Register a function to handle calls made to action on this domain. If the domain object represents a domain like `xs.demo.user.app` the 
 * endpoint that the handler is registered to will look like `xs.demo.user.app/action`.
 * @returns {Promise} a promise that is resolved if the handler is successfully registered or rejected if there is an error.
 * @example
 * //**Registering a Procedure**
 * //register an action call hello on our top level app domain. i.e. xs.demo.user.app/hello
 * app.register('hello', function(){
 *   console.log('hello');
 * });
 */

/**
 * @memberof RiffleDomain
 * @function call
 * @param {string} action - The action the function being called is registered under on the domain.
 * @param {...*} args - The arguments to provide to the function being called.
 * @description Call a function already registered to an action on this domain. If the domain object represents an domain like `xs.demo.user.app` the 
 * endpoint that is called to will look like `xs.demo.user.app/action`.
 * @returns {RifflePromise} Returns a regular promise but with an extra {@link RifflePromise.want} function that can be used to specify the expected result type
 * @example
 * //**Call w/optional type checking**
 * //call an action sum on with two numbers on our top level app domain. i.e. xs.demo.user.app/sum
 * var p = app.call('sum', 1, 1);
 *
 * //anyHandler will be called if the call is successful no matter what the result error1 will be called if there an error
 * p.then(anyHandler, error);
 *
 * //numHandler will only be called if the result from the call is a number
 * //numError will be called if the response is not a number or any other error
 * p.want(Number).then(numHandler, numError);
 */

/**
 * @memberof RiffleDomain
 * @function publish
 * @param {string} channel - The channel the being published to on the domain.
 * @param {...*} args - The arguments to publish to the channel.
 * @description Publish data to any subscribers listening on a given channel on the domain. If the {@link RiffleDomain domain} represents a domain like `xs.demo.user.app` the 
 * endpoint that is published to will look like `xs.demo.user.app/channel`.
 * @example
 * //**Publishing**
 * //publish the string 'hello' to the `ping` channel on our top level app domain. i.e. `xs.demo.user.app/ping`
 * app.publish('ping', 'hello');
 */

/**
 * @memberof RiffleDomain
 * @function subscribe
 * @param {string} channel - The channel that the handler should subscribe to under the domain.
 * @param {function} handler - The function that will handle any publishes made to the registered endpoint or a valid {@link jsRiffle.want} function.
 * @description Subscribe a function to handle publish events made to the channel on this domain. If the domain object represents an domain like `xs.demo.user.app` the 
 * endpoint that the handler is subscribed to will look like `xs.demo.user.app/channel`.
 * @returns {Promise} a promise that is resolved if the handler is successfully subscribed or rejected if there is an error.
 * @example
 * //**Subscribing to an Event**
 * //subscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
 * app.subscribe('hello', function(){
 *   console.log('Received hello event!');
 * });
 */

/**
 * @memberof RiffleDomain
 * @function unsubscribe
 * @param {string} channel - The channel that you wish to unsubscribe handlers from under the domain.
 * @description Unsubscribe all handlers subscribe to the channel on this domain. 
 * @example
 * //**Unsubscribe**
 * //unsubscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
 * app.unsubscribe('hello');
 */

/**
 * @memberof RiffleDomain
 * @function unregister
 * @param {string} action - The action that you wish to unregister the handler from under the domain.
 * @description Unregister the handler for the specified action on this domain. 
 * @example
 * //**Unregister**
 * //unregister the 'getData' action handler on our top level app domain. i.e. xs.demo.user.app/getData
 * app.unregister('getData');
 */

/**
 * @memberof RiffleDomain
 * @function subdomain
 * @param {string} name - The name of the new subdomain.
 * @description Create a subdomain from the current {@link RiffleDomain domain} object. 
 * @returns {RiffleDomain} A subdomain representing a domain with name appended to the parent domain. i.e. `xs.demo.user.app` => `xs.demo.user.app.subdomain`
 * @example
 * //**Create a subdomain**
 * //if app represents the domain xs.demo.user.app backend is a RiffleDomain that represents `xs.demo.user.app.backend`
 * var backend = app.subdomain('backend');
 */

/**
 * @memberof RiffleDomain
 * @function linkDomain
 * @param {string} fullDomain - The full name of the new domain.
 * @description Create a new domain from the current {@link RiffleDomain domain} object that represents the domain specified by fullDomain. 
 * @returns {RiffleDomain} A {@link RiffleDomain} representing a domain specified by the fullDomain argument
 * @example
 * //**Link A Domain**
 * //create a new domain that represents xs.demo.partner.app
 * var anotherApp = app.linkDomain('xs.demo.partner.app');
 */

/**
 * @memberof RiffleDomain
 * @function join
 * @description Attempts to create a connection to the Exis fabric using this domain. If successful a the `app.onJoin` function will be called
 * to notify a successful connection was established.
 * @example
 * //**Joining a domain**
 *
 * //if the join is successful this function will be triggered
 * app.onJoin = function(){
 *   console.log('Connected!');
 * };
 *
 * //attempt to join connect to Exis as the top level domain i.e. xs.demo.user.app
 * app.join();
 */

/**
 * @memberof RiffleDomain
 * @function leave
 * @description Unregister and unsubscribe anything in the domain and disconnect from Exis if this the the domain that {@link RiffleDomain.join} was called on.
 * If the connection is closed the `onLeave` will be called notifying that the session has been closed.
 * @example
 * //**Logout/Disconnect**
 *
 * //if the connection is closed this function will be triggered
 * app.onLeave = function(){
 *   console.log('Connection Closed!');
 * };
 *
 * //unregister/unsubscribe any handlers on the top level domain and close the connection if it this the the domain join was called on.
 * app.leave();
 */

/**
 * @memberof RiffleDomain
 * @function login
 * @param {object=} user - An object containing the login info for the user.
 * @param {string} user.username - The user's username as registered with Auth.
 * @param {string=} user.password - The user's password.
 * @description Log the user in via the {@link /docs/appliances/Auth Auth} appliance for this app and open the connection to Exis.
 * If the attached Auth appliance is level 1 then the user object must be provided. For level 0 you can call login with an empty object
 * to connect with at temporary random username. Passing in just the username will attempt to login the user with the given username
 * if it is available.
 * @returns {RiffleDomain} returns a promise object which is resolved upon success or rejected on failure.
 * @example 
 * //**Login Example**
 * var user = { username: "example", password: "demo" };
 * //login user 
 * app.login(user).then(function(user_domain){
 *     //now we can connect the user
 *     user_domain.join();
 *   }, errorHandler);
 */

/**
 * @memberof RiffleDomain
 * @function registerAccount
 * @param {object} user - An object containing the login info for the user.
 * @param {string} user.username - The username that the user wishes to register with.
 * @param {string} user.password - The user's password.
 * @param {string} user.name - The name of the person registering.
 * @param {string} user.email - An email to associate with the account.
 * @description Register a new user with an an Auth appliance attached to the current app domain. Only works with {@link /docs/appliances/Auth Auth} appliances of level 1.
 * @returns {Promise} returns a promise object which is resovled upon success or rejected on failure.
 * @example 
 * //**Account Registration Example**
 * var user = { username: "example", password: "demo", name: "Johnny D", email: "example@domain.com" };
 * //register the new user 
 * app.registerAccount(user).then(registerHandler, errorHandler);
 */

/**
 * @memberof RiffleDomain
 * @function setToken
 * @param {string} token - The token for the {@link /docs/riffle/Domain domain} that is attempting to join the fabric.
 * @description Manually set a token to use for authentication for access to the Exis fabric.
 */

/**
 * @memberof RiffleDomain
 * @function getToken
 * @description Retrieve the currently be used for authentication. 
 * @returns {string} returns the token currently being used for authenticating to Exis if there is one.
 */

/**
 * @typedef RifflePromise
 * @description A RifflePromise is a regular Promise object that simply implements an extra {@link RifflePromise.want} function which specifies what the
 * expected result of a {@link RiffleDomain.call} should be.
 * @example
 * //**Call type checking**
 * //call a function that and only execute our handler if the result is a string
 * app.call('getData').want(String).then(handler);
 */

/**
 * @memberof RifflePromise
 * @function want
 * @param {...Type} types - The types of expected return values. Valid types are `String`, `Number`, `[Type]`(an Array with elements of `Type`),
 * `{key1: Type, key2: Type}`(An object with keys `key1` and `key2` each of `Type`), or `ModelObject`(a valid {@link ModelObject}). 
 * @description A function which returns a promise that is resolved if the return of the call matches the types provided or is rejected otherwise.
 * @returns {Promise} Returns a regular promise that is resolved if the call succeeds an the return is of the correct type or is rejected otherwise.
 * @example
 * //call a function that and only execute our handler if the result is a string
 * app.call('getData').want(String).then(handler);
 */

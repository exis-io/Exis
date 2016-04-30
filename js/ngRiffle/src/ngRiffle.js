/**
 * @version 0.4.8
 */

/**
 * @namespace $riffleProvider
 * @description The $riffleProvider is used to configure settings for the $riffle service.
 * The functions can be used in a .config block of the application.
 * @example
 * //**Configuration Example**
 * angular.module('myapp').config(function($riffleProvider){
 *   //now set the app domain and node to connect with
 *   $riffleProvider.setFabricLocal();
 *   $riffleProvider.setDomain('xs.demo.username.myapp');
 *  });
 */

/**
 * @memberof $riffleProvider
 * @function setDomain
 * @param {string} domain - The top level domain for the application.
 * @description Sets the top level application domain.
 * @example 
 * //sets application to app1 domain 
 * $riffleProvider.setDomain('xs.demo.user.app1');
 */

/**
 * @memberof $riffleProvider
 * @function setFabric
 * @param {string} url - The url of the node to be connected to.
 * @description Sets the url of the node being connected to.
 * @example 
 * //connect to exis sandbox node 
 * $riffleProvider.setFabric('ws://sandbox.exis.io:8000/ws');
 */

/**
 * @memberof $riffleProvider
 * @function setFabricLocal
 * @description Connect to a node running locally.
 */

/**
 * @memberof $riffleProvider
 * @function setFabricProduction
 * @description Connect to node.exis.io, the Exis production node.
 */

/**
 * @memberof $riffleProvider
 * @function setFabricSandbox
 * @description Connect to sandbox.exis.io, the Exis sandbox node.
 */

/**
 * @namespace $riffle
 * @description The $riffle service is that provides an API for easy interaction with Exis. The service
 * itself represents the top-level {@link /docs/riffle/Domain domain} of the application and provides 
 * functions for creating new domain objects, and interacting with {@link ModelObject} Storage and 
 * {@link $riffle.user} storage as well.
 * @borrows RiffleDomain.call as call
 * @borrows RiffleDomain.register as register
 * @borrows RiffleDomain.publish as publish
 * @borrows RiffleDomain.subscribe as subscribe
 * @borrows RiffleDomain.subscribeOnScope as subscribeOnScope
 * @borrows RiffleDomain.unregister as unregister
 * @borrows RiffleDomain.unsubscribe as unsubscribe
 * @borrows RiffleDomain.subdomain as subdomain
 * @borrows RiffleDomain.linkDomain as linkDomain
 * @borrows RiffleDomain.join as join
 * @borrows RiffleDomain.leave as leave
 * @borrows RiffleDomain.getName as getName
 * @borrows RiffleDomain.username as username
 */

/**
 * @memberof $riffle
 * @function login
 * @param {object=} user - An object containing the login info for the user.
 * @param {string} user.username - The user's username as registered with Auth.
 * @param {string=} user.password - The user's password.
 * @description Log the user in via the {@link /docs/appliances/Auth Auth} appliance for this app and open the connection to Exis.
 * If the attached Auth appliance is level 1 then the user object must be provided. For level 0 you can call login without arguments
 * to connect with at temporary random username. Passing in just the username will attempt to login the user with the given username
 * if it is available.
 * @returns {Promise} returns a promise object which is resovled upon success or rejected on failure.
 * @example 
 * //**Login Example**
 * var user = { username: "example", password: "demo" };
 * //login user 
 * $riffle.login(user).then(loginHandler, errorHandler);
 */

/**
 * @memberof $riffle
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
 * $riffle.registerAccount(user).then(registerHandler, errorHandler);
 */

/**
 * @memberof $riffle
 * @function setToken
 * @param {string} token - The token for the {@link /docs/riffle/Domain domain} that is attempting to join the fabric.
 * @description Manually set a token to use for authentication for access to the Exis fabric.
 */

/**
 * @memberof $riffle
 * @function getToken
 * @description Retrieve the currently be used for authentication. 
 * @returns {string} returns the token currently being used for authenticating to Exis if there is one.
 */

/**
 * @memberof $riffle
 * @function modelObject
 * @param {RiffleConstructor} class - A valid {@link RiffleConstructor}
 * @description Creates a new modelObject class using the given properly formed {@link RiffleConstructor}.
 * @returns {ModelObject} A new ModelObject that can be used for interacting with Model Object Storage and the
 * {@link $riffle.want} syntax.
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
 * var person = $riffle.modelObject(Person);
 */

/**
 * @memberof $riffle
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
 * var person = $riffle.modelObject(Person);
 *
 * //register a function that accepts only a Number and a Person
 * //The caller will receive an error if the arguments aren't correct
 * //expects call that looks like $riffle.call('isOlder', 18, {first: 'John', last: 'Doe', age: 21});
 * $riffle.register('isOlder', $riffle.want(function(age, person){
 *   if(person.age > age){
 *     console.log(person.fullname + 'is older than ' + age);
 *   }
 * }, Number, person));
 *
 */

/**
 * @memberof $riffle
 * @typedef {object} user
 * @description The user object is created only if connection to the fabric is done via the {@link $riffle.login} function through
 * an {@link /docs/appliances/Auth Auth} appliance.
 * @borrows RiffleDomain.call as call
 * @borrows RiffleDomain.register as register
 * @borrows RiffleDomain.publish as publish
 * @borrows RiffleDomain.subscribe as subscribe
 * @borrows RiffleDomain.subscribeOnScope as subscribeOnScope
 * @borrows RiffleDomain.unregister as unregister
 * @borrows RiffleDomain.unsubscribe as unsubscribe
 * @borrows RiffleDomain.subdomain as subdomain
 * @borrows RiffleDomain.linkDomain as linkDomain
 * @borrows RiffleDomain.join as join
 * @borrows RiffleDomain.leave as leave
 * @borrows RiffleDomain.getName as getName
 * @borrows RiffleDomain.username as username
 */

/**
 * @memberof $riffle.user
 * @function load
 * @description Load the user data from Storage.
 * @returns {Promise} A promise that is resolved if the user data is loaded or rejected on error.
 * @example
 * //load user data
 * $riffle.user.load().then(userLoaded, error);
 */

/**
 * @memberof $riffle.user
 * @function save
 * @description Save the user data to Exis user storage. Both the private and public storage objects
 * on Exis will be overwritten with the contents of the local private and public storage objects.
 * @returns {Promise} A promise that is resolved if the user data is successfully saved or rejected on error.
 * @example
 * //save user data
 * $riffle.user.save().then(userSaved, error);
 */

/**
 * @memberof $riffle.user
 * @function getPublicData
 * @param {object=} query - Optional MongoDB {@link https://docs.mongodb.org/manual/tutorial/query-documents/ query}
 * @description Load the public user objects from Storage. Accepts an optional MongoDB 
 * {@link https://docs.mongodb.org/manual/tutorial/query-documents/ query}  object to filter results.
 * @returns {Promise} A promise that is resolved with the user documents on success or rejected on error.
 */

/**
 * @memberof $riffle.user
 * @name email
 * @type {string}
 * @description The email that the user registered with. This is loaded from the user's storage
 * on successful login and currently can't be updated via {@link $riffle.user.save}.
 */

/**
 * @memberof $riffle.user
 * @name name
 * @type {string}
 * @description The name that the user registered with. This is loaded from the user's storage
 * on successful login and currently can't be updated via {@link $riffle.user.save}.
 */

/**
 * @memberof $riffle.user
 * @name gravatar
 * @type {string}
 * @description An md5 hash of the user's email for convience in using gravatar. This is loaded from the user's storage
 * on successful login and currently can't be updated via {@link $riffle.user.save}.
 */

/**
 * @memberof $riffle.user
 * @name privateStorage
 * @type {object}
 * @description The user's private storage object. This will be loaded on successful login or via {@link $riffle.user.load}.
 * Any updates to the object can be saved to Exis' user storage via {@link $riffle.user.save}. Private storage
 * documents are only visible to the user they are associated with. For public storage see {@link $riffle.user.publicStorage}.
 */

/**
 * @memberof $riffle.user
 * @name publicStorage
 * @type {object}
 * @description The user's public storage object. This will be loaded on successful login or via {@link $riffle.user.load}.
 * Any updates to the object can be saved to Exis' user storage via {@link $riffle.user.save}. All registered 
 * user's off an application have access to any public storage documents.
 */

/**
 * @typedef ModelObject
 * @description The ModelObject class is used to to wrap a custom JavaScript class and provides an API for interaction with
 * Model Object Storage via a {@link /docs/appliances/Storage Storage} appliance. It can also be provided as an argument to
 * {@link $riffle.want} to ensure objects recieved have the correct properties 
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
 * var person = $riffle.modelObject(Person);
 */

/**
 * @memberof ModelObject
 * @function bind
 * @param {RiffleDomain} domain - A {@link RiffleDomain} object representing the attached {@link /docs/appliances/Storage Storage} appliance
 * or a domain currently connected to Exis.
 * @param {string=} storage - The fully qualified domain of the {@link /docs/appliances/Storage Storage} appliance which to bind this ModelObject collection.
 * If none is provided the `domain` object is assumed to be the {@link /docs/appliances/Storage Storage} appliance.
 * @param {string=} collection - The name of the collection to bind the instance to. If none is provide the name of the class passed to {@link $riffle.modelObject} is used.
 * @description Bind this instance of the ModelObject with a collection of ModelObjects in a {@link /docs/appliances/Storage Storage} appliance.
 * Any instances constructed from the orignal {@link RiffleConstructor} or that are created as the result of either a
 * {@link $riffle.want want[reg/sub]} or a {@link RifflePromise.want want[call]} will have the {@link ModelObject#save} and {@link ModelObject#delete} functions attached to the instance.
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
 * var person = $riffle.modelObject(Person);
 *
 * //create a subdomain representing a Storage applinance
 * var storage = $riffle.subdomain('Storage');
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
 * var person = $riffle.modelObject(Person);
 *
 * //create a subdomain representing a Storage applinance
 * var storage = $riffle.subdomain('Storage');
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
 * var person = $riffle.modelObject(Person);
 *
 * //create a subdomain representing a Storage applinance
 * var storage = $riffle.subdomain('Storage');
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
 * person.find_one({first: 'Nick', last: 'Hyatt'}).then(funcition(nick){
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
 * person.find_one({first: 'Nick', last: 'Hyatt'}).then(funcition(nick){
 *   nick.delete(); //removes document from storage
 * });
 */

/**
 * @typedef RiffleConstructor
 * @description A RiffleConstructor is simply a class constructor function with the expected property set to be the expected `Type`
 * This Constructor can be used to create a {@link ModelObject} via the {@link $riffle.modelObject} function and used for as an expected
 * type for {@link $riffle.want}.
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
 * The `$riffle` service is itself the top level domain of our application and represents a domain like `xs.demo.user.app`. Creating subdomains from the `$riffle` service
 * would give us domain objects representing a domain like `xs.demo.user.app.subdomain`. Creating subdomains from any `RiffleDomain` always creates a new domain object
 * with its namespace one level lower than it's parent.
 * @example
 * //construct a valid subdomain from $riffle service
 * var backend = $riffle.subdomain('backend');
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
 * $riffle.getName(); //returns 'xs.demo.developer.app'
 */

/**
 * @memberof RiffleDomain
 * @function username
 * @description Returns the final portion of domain.
 * @returns {string} The final portion of the domain. i.e. `xs.demo.user.app.username` => `username`
 * @example
 * $riffle.user.username(); //returns 'username'
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
 * $riffle.register('hello', function(){
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
 * var p = $riffle.call('sum', 1, 1);
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
 * $riffle.publish('ping', 'hello');
 */

/**
 * @memberof RiffleDomain
 * @function subscribe
 * @param {string} channel - The channel that the handler should subscribe to under the domain.
 * @param {function} handler - The function that will handle any publishes made to the registered endpoint or a valid {@link $riffle.want} function.
 * @description Subscribe a function to handle publish events made to the channel on this domain. If the domain object represents an domain like `xs.demo.user.app` the 
 * endpoint that the handler is subscribed to will look like `xs.demo.user.app/channel`.
 * @returns {Promise} a promise that is resolved if the handler is successfully subscribed or rejected if there is an error.
 * @example
 * //**Subscribing to an Event**
 * //subscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
 * $riffle.subscribe('hello', function(){
 *   console.log('Received hello event!');
 * });
 */

/**
 * @memberof RiffleDomain
 * @function subscribeOnScope
 * @param {object} scope - The $scope that the subscribe should be bound to.
 * @param {string} channel - The channel that the handler should subscribe to under the domain.
 * @param {function} handler - The function that will handle any publishes made to the registered endpoint or a valid {@link $riffle.want} function.
 * @description Creates a subscription via {@link RiffleDomain.subscribe} but binds it to the provided scope so that on destruction of the scope the handler is unsubscribed.
 * @returns {Promise} a promise that is resolved if the handler is successfully subscribed or rejected if there is an error.
 * @example
 * //**Subscribing on a $scope**
 * //subscribe to events published to hello on our top level app domain and bind the subscription to $scope
 * //when $scope.$on('$destroy') is triggered the handler will be unsubscribed
 * $riffle.subscribeOnScope($scope, 'hello', function(){
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
 * $riffle.unsubscribe('hello');
 */

/**
 * @memberof RiffleDomain
 * @function unregister
 * @param {string} action - The action that you wish to unregister the handler from under the domain.
 * @description Unregister the handler for the specified action on this domain. 
 * @example
 * //**Unregister**
 * //unregister the 'getData' action handler on our top level app domain. i.e. xs.demo.user.app/getData
 * $riffle.unregister('getData');
 */

/**
 * @memberof RiffleDomain
 * @function subdomain
 * @param {string} name - The name of the new subdomain.
 * @description Create a subdomain from the current {@link RiffleDomain domain} object. 
 * @returns {RiffleDomain} A subdomain representing a domain with name appended to the parent domain. i.e. `xs.demo.user.app` => `xs.demo.user.app.subdomain`
 * @example
 * //**Create a subdomain**
 * //if $riffle represents the domain xs.demo.user.app backend is a RiffleDomain that represents `xs.demo.user.app.backend`
 * var backend = $riffle.subdomain('backend');
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
 * var anotherApp = $riffle.linkDomain('xs.demo.partner.app');
 */

/**
 * @memberof RiffleDomain
 * @function join
 * @description Attempts to create a connection to the Exis fabric using this domain. If successful a `$riffle.open` event will be broadcast throughout the app
 * to notify listening handlers that a successful connection was established.
 * @example
 * //**Joining a domain**
 * //attempt to join connect to Exis as the top level domain i.e. xs.demo.user.app
 * $riffle.join();
 *
 * //if the join is successful this function will be triggered
 * $scope.$on('$riffle.open', function(){
 *   console.log('Connected!');
 * });
 */

/**
 * @memberof RiffleDomain
 * @function leave
 * @description Unregister and unsubscribe anything in the domain and disconnect from Exis if this the the domain that {@link RiffleDomain.join} was called on.
 * If the connection is closed a `$riffle.leave` event will be broadcast thoughout the app to notify listening handlers that the session has been closed.
 * @example
 * //**Logout/Disconnect**
 * //unregister/unsubscribe any handlers on the top level domain and close the connection if it this the the domain join was called on.
 * $riffle.leave();
 *
 * //if the connection is closed this function will be triggered
 * $scope.$on('$riffle.leave', function(){
 *   console.log('Connection Closed!');
 * });
 */

/**
 * @typedef RifflePromise
 * @description A RifflePromise is a regular Promise object that simply implements an extra {@link RifflePromise.want} function which specifies what the
 * expected result of a {@link RiffleDomain.call} should be.
 * @example
 * //call a function that and only execute our handler if the result is a string
 * $riffle.call('getData').want(String).then(handler);
 */

/**
 * @memberof RifflePromise
 * @function want
 * @param {...Type} types - The types of expected return values. Valid types are `String`, `Number`, `[Type]`(an Array with elements of `Type`),
 * `{key1: Type, key2: Type}`(An object with keys `key1` and `key2` each of `Type`), or `ModelObject`(a valid {@link ModelObject}). 
 * @description A function which returns a promise that is resolved if the return of the call matches the types provided or is rejected otherwise.
 * @returns {Promise} Returns a regular promise that is resolved if the call succeeds an the return is of the correct type or is rejected otherwise.
 * @example
 * //**Call type checking**
 * //call a function that and only execute our handler if the result is a string
 * $riffle.call('getData').want(String).then(handler);
 */

if (typeof module !== "undefined" && typeof exports !== "undefined" && module.exports === exports){
    var jsriffle = require('jsRiffle');
    module.exports = 'ngRiffle';
}

(function () {
    'use strict';


    var ngRiffleModule = angular.module('ngRiffle', []).provider('$riffle', $RiffleProvider);

    function $RiffleProvider() {

        var id = undefined;
        var providerAPIExcludes = ['Application', 'Domain', 'modelObject', 'want', 'xsStorage', 'xsPromises', 'xsFileStorage'];
        for(var key in jsRiffle){
          if(providerAPIExcludes.indexOf(key) === -1){
            this[key] = jsRiffle[key];
          }
        }

        this.setDomain = function(domain){
          id = domain;
        };


        var interceptors = this.interceptors = [];

        this.$get = ["$rootScope", "$q", "$log", "$injector", function ($rootScope, $q, $log, $injector) {

            /*
             * Interceptors stored in reverse order. Inner interceptors before outer interceptors.
             */
            var reversedInterceptors = [];

            angular.forEach(interceptors, function (interceptor) {
                reversedInterceptors.unshift(
                    angular.isString(interceptor) ? $injector.get(interceptor) :  $injector.invoke(interceptor));
            });

            /*
             * @param func
             * @returns {Function}
             *
             * @description
             * Wraps a callback with a function that calls scope.$apply(), so that the callback is added to the digest
             */
            function digestWrapper(func) {

                return function () {
                    var cb = func.apply(this, arguments);
                    $rootScope.$apply();
                    return cb;
                };
            }

            var connection;
            var sessionDeferred = $q.defer();
            var sessionPromise = sessionDeferred.promise;
            
            var joinFnc = digestWrapper(function () {
                $log.debug("Connection Opened: ");
                $rootScope.$broadcast("$riffle.open");
                connection.connected = true;
                sessionDeferred.resolve();
            });

            var leaveFnc = digestWrapper(function (reason, details) {
                $log.debug("Connection Closed: ", reason, details);
                connection.connected = false;
                sessionDeferred = $q.defer();
                sessionPromise = sessionDeferred.promise;
                $rootScope.$broadcast("$riffle.leave", {reason: reason, details: details});
            });


            connection = new DomainWrapper(jsRiffle.Domain(id));
            connection.want = jsRiffle.want;
            connection.modelObject = jsRiffle.modelObject;
            connection.xsStorage = function(domain){
              domain = domain || connection.linkDomain(connection.getName() + '.Storage');
              return jsRiffle.xsStorage(domain);
            };
            connection.xsAuth = function(domain){
              domain = domain || connection.linkDomain(connection.getName() + '.Auth');
              return jsRiffle.xsAuth(domain);
            };
            connection.xsContainers = function(domain){
              domain = domain || connection.linkDomain(connection.getName() + '.Container');
              return jsRiffle.xsContainers(domain);
            };
            connection.xsReplay = function(domain){
              domain = domain || connection.linkDomain(connection.getName() + '.Replay');
              return jsRiffle.xsReplay(domain);
            };
            connection.xsBouncer = function(){return jsRiffle.xsBouncer(connection.linkDomain('xs.demo.Bouncer'));};
            connection.xsFileStorage = function(){return jsRiffle.xsFileStorage(connection.linkDomain('xs.demo.FileStorage'));};
            connection.connected = false;

            
            /*
             * Wraps WAMP actions, so that when they're called, the defined interceptors get called before the result is returned
             *
             * @param type
             * @param args
             * @param callback
             * @returns {*}
             */
            var interceptorWrapper = function (type, args, callback) {

                var result = function (result) {
                    return {result: result, type: type, args: args};
                };

                var error = function (error) {
                    //$log.error("$riffle error", {type: type, arguments: args, error: error});
                    return $q.reject({error: error, type: type, args: args});
                };

                // Only execute the action callback once we have an established session
                var action = sessionPromise.then(function () {
                    return callback();
                });

                var chain = [result, error];

                // Apply interceptors
                angular.forEach(reversedInterceptors, function (interceptor) {
                    if (interceptor[type + 'Response'] || interceptor[type + 'ResponseError']) {
                        chain.push(interceptor[type + 'Response'], interceptor[type + 'ResponseError']);
                    }
                });

                // We only want to return the actually result or error, not the entire information object
                chain.push(
                    function (response) {
                        return response.result;
                    }, function (response) {
                        return $q.reject(response.error);
                    }
                );

                while (chain.length) {
                    var resolved = chain.shift();
                    var rejected = chain.shift();

                    action = action.then(resolved, rejected);
                }

                return action;
            };

            function DomainWrapper(riffleDomain){
              this.conn = riffleDomain;
              this.conn.onJoin = joinFnc;
              this.conn.onLeave = leaveFnc;
            }
            DomainWrapper.prototype.join = function(){
              return this.conn.join();
            };
            DomainWrapper.prototype.leave = function(){
              return this.conn.leave();
            };
            DomainWrapper.prototype.subscribeOnScope = function(scope, channel, callback){
              var self = this;
              return this.subscribe(channel, callback).then(function(){
                scope.$on('$destroy', function () {
                  return self.unsubscribe(channel);
                });
              });
            };
            DomainWrapper.prototype.setToken = function(tok) {
                this.conn.setToken(tok);
            };
            DomainWrapper.prototype.getToken = function() {
                return this.conn.getToken();
            };
            DomainWrapper.prototype.getName = function() {
                return this.conn.getName();
            };
            DomainWrapper.prototype.username = function() {
                return this.conn.getName().split('.')[this.conn.getName().split('.').length-1];
            };
            DomainWrapper.prototype.unsubscribe = function (channel) {
              var self = this;
              return interceptorWrapper('unsubscribe', arguments, function () {
                return self.conn.unsubscribe(channel);
              });
            };
            DomainWrapper.prototype.publish = function(){
              var a = arguments
              var self = this;
              return interceptorWrapper('publish', arguments, function(){
                return self.conn.publish.apply(self.conn, a);
              });
            };
            DomainWrapper.prototype.register = function (action, handler) {
              if(typeof(handler) === 'function'){
                handler = digestWrapper(handler);
              }else{
                handler.fp = digestWrapper(handler.fp);
              }
              var self = this;
              return interceptorWrapper('register', arguments, function () {
                return self.conn.register(action, handler);
              });
            };
            DomainWrapper.prototype.subscribe = function (action, handler) {
              if(typeof(handler) === 'function'){
                handler = digestWrapper(handler);
              }else{
                handler.fp = digestWrapper(handler.fp);
              }
              var self = this;
              return interceptorWrapper('subscribe', arguments, function () {
                return self.conn.subscribe(action, handler);
              });
            };
            DomainWrapper.prototype.unregister = function (registration) {
              var self = this;
              return interceptorWrapper('unregister', arguments, function () {
                return self.conn.unregister(registration);
              });
            };
            DomainWrapper.prototype.call = function () {
              var a = arguments
              var self = this;
              var callPromise = undefined;
              var types = undefined;
              var callPromiseInit = $q.defer();

              function wantIntercept() {
                return interceptorWrapper('want', a, function() {
                  return callPromise.want.apply({}, types)
                });
              }

              function want(){
                types = arguments;
                return callPromiseInit.promise.then(wantIntercept);
              }

              var inter = interceptorWrapper('call', arguments, function () {
                callPromise = self.conn.call.apply(self.conn, a);
                callPromiseInit.resolve();
                return callPromise;
              });

              inter.want = want;
              
              return inter;
            };
            DomainWrapper.prototype.subdomain = function(id) {
              return new DomainWrapper(this.conn.subdomain(id));
            };
            DomainWrapper.prototype.linkDomain = function(id) {
              return new DomainWrapper(this.conn.linkDomain(id));
            };
            DomainWrapper.prototype.login = function(user) {
              user = user || {};
              var self = this;
              //deferred for knowing when process is done
              var userDeferred = $q.defer();

              //figure out auth level from user object
              var auth0 = false;
              if(!user.password){
                auth0 = true;
              }
              
              function resolve(){
                userDeferred.resolve(connection.user);
              }

              //if we are auth1 load user data
              function load(){
                connection.user.load().then(userDeferred.resolve, userDeferred.reject);
              }

              //if we get success from the registrar on login continue depending on auth level
              function success(domain){
                if(auth0){
                  //if auth0 then we don't have user storage
                  connection.user = new DomainWrapper(domain); 
                  connection.user.join();
                  sessionPromise.then(resolve);
                }else{
                  //if auth1 use user class to wrap domain and implement user storage and load user data
                  connection.user = new User(self, domain); 
                  connection.user.join();
                  sessionPromise.then(load);
                }
              }

              //attempt registration login and continue process on success
              this.conn.login(user).then(success, userDeferred.reject);

              //return the promise which will be resolved once the login process completes.
              return userDeferred.promise;
            };
            DomainWrapper.prototype.registerAccount = function(user) {
              return this.conn.registerAccount(user);
            };

            function User(app, domain) {
              DomainWrapper.call(this, domain);
              this.storage = app.subdomain("Auth");
            }
            User.prototype = Object.create(DomainWrapper.prototype);
            User.prototype.constructor = User;
            User.prototype.email = "";
            User.prototype.name = "";
            User.prototype.privateStorage = {};
            User.prototype.publicStorage = {};
            User.prototype.save = function(){
              return this.storage.call('save_user_data', this.publicStorage, this.privateStorage);
            };
            User.prototype.load = function(){
              var self = this;
              var loadDeferred = $q.defer();
              function loadUser(user){
                self.name = user.name;
                self.email = user.email;
                self.gravatar = user.gravatar;
                self.privateStorage = user.private || {};
                self.publicStorage = user.public || {};
                loadDeferred.resolve(self);
              }
              function error(error){
                loadDeferred.reject(error);
              }
              this.storage.call('get_user_data').then(loadUser, error);
              return loadDeferred.promise;
            };
            User.prototype.getPublicData = function(query){
              return this.storage.call('get_public_data', query)
            };



            /*
             * Subscription object which self manages reconnections
             * @param topic
             * @param handler
             * @param options
             * @param subscribedCallback
             * @returns {{}}
             * @constructor
            var Subscription = function (topic, handler, options, subscribedCallback) {

                var subscription = {}, unregister, onOpen, deferred = $q.defer();

                handler = digestWrapper(handler);

                onOpen = function () {
                    var p = connection.session.subscribe(topic, handler, options).then(
                        function (s) {
                            if (subscription.hasOwnProperty('id')) {
                                delete subscription.id;
                            }

                            subscription = angular.extend(s, subscription);
                            deferred.resolve(subscription);
                            return s;
                        }
                    );
                    if (subscribedCallback) {
                        subscribedCallback(p);
                    }

                };

                if (connection.isOpen) {
                    onOpen();
                }

                unregister = $rootScope.$on("$riffle.open", onOpen);

                subscription.promise = deferred.promise;
                subscription.unsubscribe = function () {
                    unregister(); //Remove the event listener, so this object can get cleaned up by gc
                    return connection.session.unsubscribe(subscription);
                };

                return subscription.promise;
            };
             */


            return connection;
        }];

        return this;

    }
})();

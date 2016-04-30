# ngRiffle (v0.4.9)
ngRiffle is an AngularJS service that wraps the [jsRiffle](https://github.com/exis-io/jsRiffle) library and provides an API for connection and interaction with Exis.


## Changes in v0.4.9
* [Auth](#Auth) Appliance API added.
* [Bouncer](#Bouncer) Appliance API added.
* [Container](#Container) Appliance API added.
* [Replay](#Replay) Appliance API added.
* [FileStorage](#FileStorage) Appliance API added for uploading files to Exis's Cloud Storage system.


## Objects

<dl>
<dt><a href="#$riffleProvider">$riffleProvider</a> : <code>object</code></dt>
<dd><p>The $riffleProvider is used to configure settings for the $riffle service.
The functions can be used in a .config block of the application.</p>
</dd>
<dt><a href="#$riffle">$riffle</a> : <code>object</code></dt>
<dd><p>The $riffle service is that provides an API for easy interaction with Exis. The service
itself represents the top-level <a href="/docs/riffle/Domain">domain</a> of the application and provides 
functions for creating new domain objects, and interacting with <a href="#ModelObject">ModelObject</a> Storage and 
<a href="#$riffle.user">user</a> storage as well.</p>
</dd>
</dl>

## Typedefs

<dl>
<dt><a href="#ModelObject">ModelObject</a></dt>
<dd><p>The ModelObject class is used to to wrap a custom JavaScript class and provides an API for interaction with
Model Object Storage via a <a href="/docs/appliances/Storage">Storage</a> appliance. It can also be provided as an argument to
<a href="#$riffle.want">want</a> to ensure objects recieved have the correct properties 
and are constructed with the correct prototype.</p>
</dd>
<dt><a href="#RiffleConstructor">RiffleConstructor</a></dt>
<dd><p>A RiffleConstructor is simply a class constructor function with the expected property set to be the expected <code>Type</code>
This Constructor can be used to create a <a href="#ModelObject">ModelObject</a> via the <a href="#$riffle.modelObject">modelObject</a> function and used for as an expected
type for <a href="#$riffle.want">want</a>.</p>
</dd>
<dt><a href="#RiffleDomain">RiffleDomain</a></dt>
<dd><p>A RiffleDomain is an object which represents a specific <a href="/docs/riffle/Domain">domain</a> on Exis and
provides an API for performing actions such as <a href="#RiffleDomain.register">register</a> and <a href="#RiffleDomain.call">call</a> on behalf of the <a href="/docs/riffle/Domain">domain</a>.
The <code>$riffle</code> service is itself the top level domain of our application and represents a domain like <code>xs.demo.user.app</code>. Creating subdomains from the <code>$riffle</code> service
would give us domain objects representing a domain like <code>xs.demo.user.app.subdomain</code>. Creating subdomains from any <code>RiffleDomain</code> always creates a new domain object
with its namespace one level lower than it&#39;s parent.</p>
</dd>
<dt><a href="#RifflePromise">RifflePromise</a></dt>
<dd><p>A RifflePromise is a regular Promise object that simply implements an extra <a href="#RifflePromise.want">want</a> function which specifies what the
expected result of a <a href="#RiffleDomain.call">call</a> should be.</p>
</dd>
<dt><a href="#Auth">Auth</a></dt>
<dd><p>The Auth class provides an API for interacting with an <a href="/docs/appliances/Auth">Auth</a> Appliance</p>
</dd>
<dt><a href="#Bouncer">Bouncer</a></dt>
<dd><p>The Bouncer class provides an API for interacting with the <a href="/docs/appliances/Bouncer">Bouncer</a> Appliance</p>
</dd>
<dt><a href="#Container">Container</a></dt>
<dd><p>The Container class provides an API for interacting with an <a href="/docs/appliances/Container">Container</a> Appliance</p>
</dd>
<dt><a href="#FileStorage">FileStorage</a></dt>
<dd><p>The FileStorage class provides an API for interacting with Exis&#39; Cloud FileStorage system</p>
</dd>
<dt><a href="#Replay">Replay</a></dt>
<dd><p>The Replay class provides an API for interacting with an <a href="/docs/appliances/Replay">Replay</a> Appliance</p>
</dd>
<dt><a href="#RiffleStorage">RiffleStorage</a></dt>
<dd><p>The RiffleStorage class links to a <a href="/docs/appliances/Storage">Storage</a> appliance and allows for creating 
<a href="#RiffleCollection">collection</a> objects.</p>
</dd>
<dt><a href="#RiffleCollection">RiffleCollection</a></dt>
<dd><p>The RiffleCollection class links to a <a href="/docs/appliances/Storage">Storage</a> appliance and allows for interacting with
<a href="#RiffleCollection">collections</a>.</p>
</dd>
</dl>

<a name="$riffleProvider"></a>
## $riffleProvider : <code>object</code>
The $riffleProvider is used to configure settings for the $riffle service.
The functions can be used in a .config block of the application.

**Kind**: global namespace  
**Example**  
```js
//**Configuration Example**
angular.module('myapp').config(function($riffleProvider){
  //now set the app domain and node to connect with
  $riffleProvider.setFabricLocal();
  $riffleProvider.setDomain('xs.demo.username.myapp');
 });
```

* [$riffleProvider](#$riffleProvider) : <code>object</code>
    * [.setDomain(domain)](#$riffleProvider.setDomain)
    * [.setFabric(url)](#$riffleProvider.setFabric)
    * [.setFabricLocal()](#$riffleProvider.setFabricLocal)
    * [.setFabricProduction()](#$riffleProvider.setFabricProduction)
    * [.setFabricSandbox()](#$riffleProvider.setFabricSandbox)

<a name="$riffleProvider.setDomain"></a>
### $riffleProvider.setDomain(domain)
Sets the top level application domain.

**Kind**: static method of <code>[$riffleProvider](#$riffleProvider)</code>  

| Param | Type | Description |
| --- | --- | --- |
| domain | <code>string</code> | The top level domain for the application. |

**Example**  
```js
//sets application to app1 domain 
$riffleProvider.setDomain('xs.demo.user.app1');
```
<a name="$riffleProvider.setFabric"></a>
### $riffleProvider.setFabric(url)
Sets the url of the node being connected to.

**Kind**: static method of <code>[$riffleProvider](#$riffleProvider)</code>  

| Param | Type | Description |
| --- | --- | --- |
| url | <code>string</code> | The url of the node to be connected to. |

**Example**  
```js
//connect to exis sandbox node 
$riffleProvider.setFabric('ws://sandbox.exis.io:8000/ws');
```
<a name="$riffleProvider.setFabricLocal"></a>
### $riffleProvider.setFabricLocal()
Connect to a node running locally.

**Kind**: static method of <code>[$riffleProvider](#$riffleProvider)</code>  
<a name="$riffleProvider.setFabricProduction"></a>
### $riffleProvider.setFabricProduction()
Connect to node.exis.io, the Exis production node.

**Kind**: static method of <code>[$riffleProvider](#$riffleProvider)</code>  
<a name="$riffleProvider.setFabricSandbox"></a>
### $riffleProvider.setFabricSandbox()
Connect to sandbox.exis.io, the Exis sandbox node.

**Kind**: static method of <code>[$riffleProvider](#$riffleProvider)</code>  
<a name="$riffle"></a>
## $riffle : <code>object</code>
The $riffle service is that provides an API for easy interaction with Exis. The service
itself represents the top-level [domain](/docs/riffle/Domain) of the application and provides 
functions for creating new domain objects, and interacting with [ModelObject](#ModelObject) Storage and 
[user](#$riffle.user) storage as well.

**Kind**: global namespace  

* [$riffle](#$riffle) : <code>object</code>
    * [.login([user])](#$riffle.login) ⇒ <code>Promise</code>
    * [.registerAccount(user)](#$riffle.registerAccount) ⇒ <code>Promise</code>
    * [.setToken(token)](#$riffle.setToken)
    * [.getToken()](#$riffle.getToken) ⇒ <code>string</code>
    * [.modelObject(class)](#$riffle.modelObject) ⇒ <code>[ModelObject](#ModelObject)</code>
    * [.want(handler, ...types)](#$riffle.want) ⇒ <code>function</code>
    * [.xsAuth([domain])](#$riffle.xsAuth) ⇒ <code>[Auth](#Auth)</code>
    * [.xsBouncer()](#$riffle.xsBouncer) ⇒ <code>[Bouncer](#Bouncer)</code>
    * [.xsContainers([domain])](#$riffle.xsContainers) ⇒ <code>[Container](#Container)</code>
    * [.xsFileStorage()](#$riffle.xsFileStorage) ⇒ <code>[FileStorage](#FileStorage)</code>
    * [.xsReplay([domain])](#$riffle.xsReplay) ⇒ <code>[Replay](#Replay)</code>
    * [.xsStorage(domain)](#$riffle.xsStorage) ⇒ <code>[RiffleStorage](#RiffleStorage)</code>
    * [.call(action, ...args)](#$riffle.call) ⇒ <code>[RifflePromise](#RifflePromise)</code>
    * [.register(action, handler)](#$riffle.register) ⇒ <code>Promise</code>
    * [.publish(channel, ...args)](#$riffle.publish)
    * [.subscribe(channel, handler)](#$riffle.subscribe) ⇒ <code>Promise</code>
    * [.subscribeOnScope(scope, channel, handler)](#$riffle.subscribeOnScope) ⇒ <code>Promise</code>
    * [.unregister(action)](#$riffle.unregister)
    * [.unsubscribe(channel)](#$riffle.unsubscribe)
    * [.subdomain(name)](#$riffle.subdomain) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
    * [.linkDomain(fullDomain)](#$riffle.linkDomain) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
    * [.join()](#$riffle.join)
    * [.leave()](#$riffle.leave)
    * [.getName()](#$riffle.getName) ⇒ <code>string</code>
    * [.username()](#$riffle.username) ⇒ <code>string</code>
    * [.user](#$riffle.user) : <code>object</code>
        * [.email](#$riffle.user.email) : <code>string</code>
        * [.name](#$riffle.user.name) : <code>string</code>
        * [.gravatar](#$riffle.user.gravatar) : <code>string</code>
        * [.privateStorage](#$riffle.user.privateStorage) : <code>object</code>
        * [.publicStorage](#$riffle.user.publicStorage) : <code>object</code>
        * [.load()](#$riffle.user.load) ⇒ <code>Promise</code>
        * [.save()](#$riffle.user.save) ⇒ <code>Promise</code>
        * [.getPublicData([query])](#$riffle.user.getPublicData) ⇒ <code>Promise</code>
        * [.call(action, ...args)](#$riffle.user.call) ⇒ <code>[RifflePromise](#RifflePromise)</code>
        * [.register(action, handler)](#$riffle.user.register) ⇒ <code>Promise</code>
        * [.publish(channel, ...args)](#$riffle.user.publish)
        * [.subscribe(channel, handler)](#$riffle.user.subscribe) ⇒ <code>Promise</code>
        * [.subscribeOnScope(scope, channel, handler)](#$riffle.user.subscribeOnScope) ⇒ <code>Promise</code>
        * [.unregister(action)](#$riffle.user.unregister)
        * [.unsubscribe(channel)](#$riffle.user.unsubscribe)
        * [.subdomain(name)](#$riffle.user.subdomain) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
        * [.linkDomain(fullDomain)](#$riffle.user.linkDomain) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
        * [.join()](#$riffle.user.join)
        * [.leave()](#$riffle.user.leave)
        * [.getName()](#$riffle.user.getName) ⇒ <code>string</code>
        * [.username()](#$riffle.user.username) ⇒ <code>string</code>

<a name="$riffle.login"></a>
### $riffle.login([user]) ⇒ <code>Promise</code>
Log the user in via the [Auth](/docs/appliances/Auth) appliance for this app and open the connection to Exis.
If the attached Auth appliance is level 1 then the user object must be provided. For level 0 you can call login without arguments
to connect with at temporary random username. Passing in just the username will attempt to login the user with the given username
if it is available.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>Promise</code> - returns a promise object which is resovled upon success or rejected on failure.  

| Param | Type | Description |
| --- | --- | --- |
| [user] | <code>object</code> | An object containing the login info for the user. |
| user.username | <code>string</code> | The user's username as registered with Auth. |
| [user.password] | <code>string</code> | The user's password. |

**Example**  
```js
//**Login Example**
var user = { username: "example", password: "demo" };
//login user 
$riffle.login(user).then(loginHandler, errorHandler);
```
<a name="$riffle.registerAccount"></a>
### $riffle.registerAccount(user) ⇒ <code>Promise</code>
Register a new user with an an Auth appliance attached to the current app domain. Only works with [Auth](/docs/appliances/Auth) appliances of level 1.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>Promise</code> - returns a promise object which is resovled upon success or rejected on failure.  

| Param | Type | Description |
| --- | --- | --- |
| user | <code>object</code> | An object containing the login info for the user. |
| user.username | <code>string</code> | The username that the user wishes to register with. |
| user.password | <code>string</code> | The user's password. |
| user.name | <code>string</code> | The name of the person registering. |
| user.email | <code>string</code> | An email to associate with the account. |

**Example**  
```js
//**Account Registration Example**
var user = { username: "example", password: "demo", name: "Johnny D", email: "example@domain.com" };
//register the new user 
$riffle.registerAccount(user).then(registerHandler, errorHandler);
```
<a name="$riffle.setToken"></a>
### $riffle.setToken(token)
Manually set a token to use for authentication for access to the Exis fabric.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  

| Param | Type | Description |
| --- | --- | --- |
| token | <code>string</code> | The token for the [domain](/docs/riffle/Domain) that is attempting to join the fabric. |

<a name="$riffle.getToken"></a>
### $riffle.getToken() ⇒ <code>string</code>
Retrieve the currently be used for authentication.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>string</code> - returns the token currently being used for authenticating to Exis if there is one.  
<a name="$riffle.modelObject"></a>
### $riffle.modelObject(class) ⇒ <code>[ModelObject](#ModelObject)</code>
Creates a new modelObject class using the given properly formed [RiffleConstructor](#RiffleConstructor).

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>[ModelObject](#ModelObject)</code> - A new ModelObject that can be used for interacting with Model Object Storage and the
[want](#$riffle.want) syntax.  

| Param | Type | Description |
| --- | --- | --- |
| class | <code>[RiffleConstructor](#RiffleConstructor)</code> | A valid [RiffleConstructor](#RiffleConstructor) |

**Example**  
```js
//create a custom Person class
function Person(){
  this.first = String;
  this.last = String;
  this.age = Number;
}

Person.prototype.fullname = function(){
  return this.first + ' ' + this.last;
}
//create a ModelObect class representing our Person class
var person = $riffle.modelObject(Person);
```
<a name="$riffle.want"></a>
### $riffle.want(handler, ...types) ⇒ <code>function</code>
Takes the handler and the expected types that the subscribe or register handler expects and ensures
that the handler is only called if the data is correctly formatted. If the type wanted is a [ModelObject](#ModelObject)
then the data is constructed to be of the proper [ModelObject](#ModelObject) class.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>function</code> - A new function which can be passed in as the handler of a [subscribe](subscribe) or [register](register) call
to ensure the handlers are only called if the data is properly formatted.  
**See**: [here](#RifflePromise.want) for information about wants and expecting returns from [calls](#RiffleDomain.call).  

| Param | Type | Description |
| --- | --- | --- |
| handler | <code>function</code> | A function that handles the call/publish events. |
| ...types | <code>Type</code> | A list of the Types the handler expects as arguments. Valid types are `String`, `Number`, `[Type]`(an Array with elements of `Type`), `{key1: Type, key2: Type}`(An object with keys `key1` and `key2` each of `Type`), or `ModelObject`(a valid [ModelObject](#ModelObject)). |

**Example**  
```js
//create a custom Person class
function Person(){
  this.first = String;
  this.last = String;
  this.age = Number;
}

Person.prototype.fullname = function(){
  return this.first + ' ' + this.last;
}
//create a ModelObect class representing our Person class
var person = $riffle.modelObject(Person);

//register a function that accepts only a Number and a Person
//The caller will receive an error if the arguments aren't correct
//expects call that looks like $riffle.call('isOlder', 18, {first: 'John', last: 'Doe', age: 21});
$riffle.register('isOlder', $riffle.want(function(age, person){
  if(person.age > age){
    console.log(person.fullname + 'is older than ' + age);
  }
}, Number, person));
```
<a name="$riffle.xsAuth"></a>
### $riffle.xsAuth([domain]) ⇒ <code>[Auth](#Auth)</code>
Creates a new [Auth](#Auth) class using the given properly formed [RiffleDomain](#RiffleDomain).

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>[Auth](#Auth)</code> - A new Auth object that can be used for interacting with a [Auth](/docs/appliances/Auth) Appliance.  

| Param | Type | Description |
| --- | --- | --- |
| [domain] | <code>[RiffleDomain](#RiffleDomain)</code> | A valid [RiffleDomain](#RiffleDomain) that represents the [Auth](/docs/appliances/Auth) appliance. Defaults to the Auth appliance for the app. |

**Example**  
```js
//**Auth Example**

//create a Auth instance
var auth = $riffle.xsAuth();

auth.user_count().then(success, error);  
```
<a name="$riffle.xsBouncer"></a>
### $riffle.xsBouncer() ⇒ <code>[Bouncer](#Bouncer)</code>
Creates a new [Bouncer](#Bouncer) class using the given properly formed [RiffleDomain](#RiffleDomain).

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>[Bouncer](#Bouncer)</code> - A new Bouncer object that can be used for interacting with a [Bouncer](/docs/appliances/Bouncer) Appliance.  
**Example**  
```js
//create a Bouncer instance from the domain
var bouncer = $riffle.xsBouncer();

//assign a user to the user role for the app
bouncer.assignRole('user', app.getName(), 'xs.demo.dev.app.username' ).then(success, error);  
```
<a name="$riffle.xsContainers"></a>
### $riffle.xsContainers([domain]) ⇒ <code>[Container](#Container)</code>
Creates a new [Container](#Container) class.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>[Container](#Container)</code> - A new Container object that can be used for interacting with a [Container](/docs/appliances/Container) Appliance.  

| Param | Type | Description |
| --- | --- | --- |
| [domain] | <code>[RiffleDomain](#RiffleDomain)</code> | A valid [RiffleDomain](#RiffleDomain) that represents the [Container](/docs/appliances/Container) appliance. Defaults to the apps Container appliance. |

**Example**  
```js
//create a Container instance from the proper Container subdomain of your app
var container = $riffle.xsContainers();

//list the containers in the appliance
container.list().then(success, error);  
```
<a name="$riffle.xsFileStorage"></a>
### $riffle.xsFileStorage() ⇒ <code>[FileStorage](#FileStorage)</code>
Creates a new [FileStorage](#FileStorage) class.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>[FileStorage](#FileStorage)</code> - A new FileStorage object that can be used for interacting with Exis' Cloud FileStorage system.  
**Example**  
```js
//**Upload a File**
//create a domain representing your developer account
var fs = $riffle.xsFileStorage();

//file is a File object
fs.uploadUserFile({file: file, name: 'profile.jpg'}).then(success, error, progress); //progress is repeatedly called during upload with percent complete.
```
<a name="$riffle.xsReplay"></a>
### $riffle.xsReplay([domain]) ⇒ <code>[Replay](#Replay)</code>
Creates a new [Replay](#Replay) class.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>[Replay](#Replay)</code> - A new Replay object that can be used for interacting with a [Replay](/docs/appliances/Replay) Appliance.  

| Param | Type | Description |
| --- | --- | --- |
| [domain] | <code>[RiffleDomain](#RiffleDomain)</code> | A valid [RiffleDomain](#RiffleDomain) that represents the [Replay](/docs/appliances/Replay) appliance. Defaults to the Replay appliance for the app. |

**Example**  
```js
//**Replay Example**

//create a Replay instance from the proper Replay subdomain of your app
var replay = $riffle.xsReplay();

//add a replay listener on the channel
replay.addReplay('xs.demo.dev.app.user/notifications').then(success, error);  
```
<a name="$riffle.xsStorage"></a>
### $riffle.xsStorage(domain) ⇒ <code>[RiffleStorage](#RiffleStorage)</code>
Creates a new [RiffleStorage](#RiffleStorage) class using the given properly formed [RiffleDomain](#RiffleDomain).

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>[RiffleStorage](#RiffleStorage)</code> - A new RiffleStorage object that can be used for interacting with a [Storage](/docs/appliances/Storage) appliance.  

| Param | Type | Description |
| --- | --- | --- |
| domain | <code>[RiffleDomain](#RiffleDomain)</code> | A valid [RiffleDomain](#RiffleDomain) that represents the [Storage](/docs/appliances/Storage) appliance. |

**Example**  
```js
//**Storage Example**
//create a storage domain
var storageDomain = $riffle.subdomain('Storage');

//create a storage instance from the domain
var storage = $riffle.xsStorage(storageDomain);

//create a collection 
var cars = storage.xsCollection('cars');

//query the collection
cars.find({color: 'red'}).then(handler); //gets all red car objects from storage
```
<a name="$riffle.call"></a>
### $riffle.call(action, ...args) ⇒ <code>[RifflePromise](#RifflePromise)</code>
Call a function already registered to an action on this domain. If the domain object represents an domain like `xs.demo.user.app` the 
endpoint that is called to will look like `xs.demo.user.app/action`.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>[RifflePromise](#RifflePromise)</code> - Returns a regular promise but with an extra [want](#RifflePromise.want) function that can be used to specify the expected result type  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>string</code> | The action the function being called is registered under on the domain. |
| ...args | <code>\*</code> | The arguments to provide to the function being called. |

**Example**  
```js
//**Call w/optional type checking**
//call an action sum on with two numbers on our top level app domain. i.e. xs.demo.user.app/sum
var p = $riffle.call('sum', 1, 1);

//anyHandler will be called if the call is successful no matter what the result error1 will be called if there an error
p.then(anyHandler, error);

//numHandler will only be called if the result from the call is a number
//numError will be called if the response is not a number or any other error
p.want(Number).then(numHandler, numError);
```
<a name="$riffle.register"></a>
### $riffle.register(action, handler) ⇒ <code>Promise</code>
Register a function to handle calls made to action on this domain. If the domain object represents a domain like `xs.demo.user.app` the 
endpoint that the handler is registered to will look like `xs.demo.user.app/action`.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>Promise</code> - a promise that is resolved if the handler is successfully registered or rejected if there is an error.  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>string</code> | The action that the handler should be registered as under the domain. |
| handler | <code>function</code> | The function that will handle any calls made to the registered endpoint or a valid [want](#$riffle.want) function. |

**Example**  
```js
//**Registering a Procedure**
//register an action call hello on our top level app domain. i.e. xs.demo.user.app/hello
$riffle.register('hello', function(){
  console.log('hello');
});
```
<a name="$riffle.publish"></a>
### $riffle.publish(channel, ...args)
Publish data to any subscribers listening on a given channel on the domain. If the [domain](#RiffleDomain) represents a domain like `xs.demo.user.app` the 
endpoint that is published to will look like `xs.demo.user.app/channel`.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  

| Param | Type | Description |
| --- | --- | --- |
| channel | <code>string</code> | The channel the being published to on the domain. |
| ...args | <code>\*</code> | The arguments to publish to the channel. |

**Example**  
```js
//**Publishing**
//publish the string 'hello' to the `ping` channel on our top level app domain. i.e. `xs.demo.user.app/ping`
$riffle.publish('ping', 'hello');
```
<a name="$riffle.subscribe"></a>
### $riffle.subscribe(channel, handler) ⇒ <code>Promise</code>
Subscribe a function to handle publish events made to the channel on this domain. If the domain object represents an domain like `xs.demo.user.app` the 
endpoint that the handler is subscribed to will look like `xs.demo.user.app/channel`.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>Promise</code> - a promise that is resolved if the handler is successfully subscribed or rejected if there is an error.  

| Param | Type | Description |
| --- | --- | --- |
| channel | <code>string</code> | The channel that the handler should subscribe to under the domain. |
| handler | <code>function</code> | The function that will handle any publishes made to the registered endpoint or a valid [want](#$riffle.want) function. |

**Example**  
```js
//**Subscribing to an Event**
//subscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
$riffle.subscribe('hello', function(){
  console.log('Received hello event!');
});
```
<a name="$riffle.subscribeOnScope"></a>
### $riffle.subscribeOnScope(scope, channel, handler) ⇒ <code>Promise</code>
Creates a subscription via [subscribe](#RiffleDomain.subscribe) but binds it to the provided scope so that on destruction of the scope the handler is unsubscribed.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>Promise</code> - a promise that is resolved if the handler is successfully subscribed or rejected if there is an error.  

| Param | Type | Description |
| --- | --- | --- |
| scope | <code>object</code> | The $scope that the subscribe should be bound to. |
| channel | <code>string</code> | The channel that the handler should subscribe to under the domain. |
| handler | <code>function</code> | The function that will handle any publishes made to the registered endpoint or a valid [want](#$riffle.want) function. |

**Example**  
```js
//**Subscribing on a $scope**
//subscribe to events published to hello on our top level app domain and bind the subscription to $scope
//when $scope.$on('$destroy') is triggered the handler will be unsubscribed
$riffle.subscribeOnScope($scope, 'hello', function(){
  console.log('Received hello event!');
});
```
<a name="$riffle.unregister"></a>
### $riffle.unregister(action)
Unregister the handler for the specified action on this domain.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>string</code> | The action that you wish to unregister the handler from under the domain. |

**Example**  
```js
//**Unregister**
//unregister the 'getData' action handler on our top level app domain. i.e. xs.demo.user.app/getData
$riffle.unregister('getData');
```
<a name="$riffle.unsubscribe"></a>
### $riffle.unsubscribe(channel)
Unsubscribe all handlers subscribe to the channel on this domain.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  

| Param | Type | Description |
| --- | --- | --- |
| channel | <code>string</code> | The channel that you wish to unsubscribe handlers from under the domain. |

**Example**  
```js
//**Unsubscribe**
//unsubscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
$riffle.unsubscribe('hello');
```
<a name="$riffle.subdomain"></a>
### $riffle.subdomain(name) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
Create a subdomain from the current [domain](#RiffleDomain) object.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>[RiffleDomain](#RiffleDomain)</code> - A subdomain representing a domain with name appended to the parent domain. i.e. `xs.demo.user.app` => `xs.demo.user.app.subdomain`  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The name of the new subdomain. |

**Example**  
```js
//**Create a subdomain**
//if $riffle represents the domain xs.demo.user.app backend is a RiffleDomain that represents `xs.demo.user.app.backend`
var backend = $riffle.subdomain('backend');
```
<a name="$riffle.linkDomain"></a>
### $riffle.linkDomain(fullDomain) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
Create a new domain from the current [domain](#RiffleDomain) object that represents the domain specified by fullDomain.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>[RiffleDomain](#RiffleDomain)</code> - A [RiffleDomain](#RiffleDomain) representing a domain specified by the fullDomain argument  

| Param | Type | Description |
| --- | --- | --- |
| fullDomain | <code>string</code> | The full name of the new domain. |

**Example**  
```js
//**Link A Domain**
//create a new domain that represents xs.demo.partner.app
var anotherApp = $riffle.linkDomain('xs.demo.partner.app');
```
<a name="$riffle.join"></a>
### $riffle.join()
Attempts to create a connection to the Exis fabric using this domain. If successful a `$riffle.open` event will be broadcast throughout the app
to notify listening handlers that a successful connection was established.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Example**  
```js
//**Joining a domain**
//attempt to join connect to Exis as the top level domain i.e. xs.demo.user.app
$riffle.join();

//if the join is successful this function will be triggered
$scope.$on('$riffle.open', function(){
  console.log('Connected!');
});
```
<a name="$riffle.leave"></a>
### $riffle.leave()
Unregister and unsubscribe anything in the domain and disconnect from Exis if this the the domain that [join](#RiffleDomain.join) was called on.
If the connection is closed a `$riffle.leave` event will be broadcast thoughout the app to notify listening handlers that the session has been closed.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Example**  
```js
//**Logout/Disconnect**
//unregister/unsubscribe any handlers on the top level domain and close the connection if it this the the domain join was called on.
$riffle.leave();

//if the connection is closed this function will be triggered
$scope.$on('$riffle.leave', function(){
  console.log('Connection Closed!');
});
```
<a name="$riffle.getName"></a>
### $riffle.getName() ⇒ <code>string</code>
Get the string representation of the domain.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>string</code> - The string representation of the domain. i.e. `xs.demo.user.app`.  
**Example**  
```js
$riffle.getName(); //returns 'xs.demo.developer.app'
```
<a name="$riffle.username"></a>
### $riffle.username() ⇒ <code>string</code>
Returns the final portion of domain.

**Kind**: static method of <code>[$riffle](#$riffle)</code>  
**Returns**: <code>string</code> - The final portion of the domain. i.e. `xs.demo.user.app.username` => `username`  
**Example**  
```js
$riffle.user.username(); //returns 'username'
```
<a name="$riffle.user"></a>
### $riffle.user : <code>object</code>
The user object is created only if connection to the fabric is done via the [login](#$riffle.login) function through
an [Auth](/docs/appliances/Auth) appliance.

**Kind**: static typedef of <code>[$riffle](#$riffle)</code>  

* [.user](#$riffle.user) : <code>object</code>
    * [.email](#$riffle.user.email) : <code>string</code>
    * [.name](#$riffle.user.name) : <code>string</code>
    * [.gravatar](#$riffle.user.gravatar) : <code>string</code>
    * [.privateStorage](#$riffle.user.privateStorage) : <code>object</code>
    * [.publicStorage](#$riffle.user.publicStorage) : <code>object</code>
    * [.load()](#$riffle.user.load) ⇒ <code>Promise</code>
    * [.save()](#$riffle.user.save) ⇒ <code>Promise</code>
    * [.getPublicData([query])](#$riffle.user.getPublicData) ⇒ <code>Promise</code>
    * [.call(action, ...args)](#$riffle.user.call) ⇒ <code>[RifflePromise](#RifflePromise)</code>
    * [.register(action, handler)](#$riffle.user.register) ⇒ <code>Promise</code>
    * [.publish(channel, ...args)](#$riffle.user.publish)
    * [.subscribe(channel, handler)](#$riffle.user.subscribe) ⇒ <code>Promise</code>
    * [.subscribeOnScope(scope, channel, handler)](#$riffle.user.subscribeOnScope) ⇒ <code>Promise</code>
    * [.unregister(action)](#$riffle.user.unregister)
    * [.unsubscribe(channel)](#$riffle.user.unsubscribe)
    * [.subdomain(name)](#$riffle.user.subdomain) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
    * [.linkDomain(fullDomain)](#$riffle.user.linkDomain) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
    * [.join()](#$riffle.user.join)
    * [.leave()](#$riffle.user.leave)
    * [.getName()](#$riffle.user.getName) ⇒ <code>string</code>
    * [.username()](#$riffle.user.username) ⇒ <code>string</code>

<a name="$riffle.user.email"></a>
#### user.email : <code>string</code>
The email that the user registered with. This is loaded from the user's storage
on successful login and currently can't be updated via [save](#$riffle.user.save).

**Kind**: static property of <code>[user](#$riffle.user)</code>  
<a name="$riffle.user.name"></a>
#### user.name : <code>string</code>
The name that the user registered with. This is loaded from the user's storage
on successful login and currently can't be updated via [save](#$riffle.user.save).

**Kind**: static property of <code>[user](#$riffle.user)</code>  
<a name="$riffle.user.gravatar"></a>
#### user.gravatar : <code>string</code>
An md5 hash of the user's email for convience in using gravatar. This is loaded from the user's storage
on successful login and currently can't be updated via [save](#$riffle.user.save).

**Kind**: static property of <code>[user](#$riffle.user)</code>  
<a name="$riffle.user.privateStorage"></a>
#### user.privateStorage : <code>object</code>
The user's private storage object. This will be loaded on successful login or via [load](#$riffle.user.load).
Any updates to the object can be saved to Exis' user storage via [save](#$riffle.user.save). Private storage
documents are only visible to the user they are associated with. For public storage see [publicStorage](#$riffle.user.publicStorage).

**Kind**: static property of <code>[user](#$riffle.user)</code>  
<a name="$riffle.user.publicStorage"></a>
#### user.publicStorage : <code>object</code>
The user's public storage object. This will be loaded on successful login or via [load](#$riffle.user.load).
Any updates to the object can be saved to Exis' user storage via [save](#$riffle.user.save). All registered 
user's off an application have access to any public storage documents.

**Kind**: static property of <code>[user](#$riffle.user)</code>  
<a name="$riffle.user.load"></a>
#### user.load() ⇒ <code>Promise</code>
Load the user data from Storage.

**Kind**: static method of <code>[user](#$riffle.user)</code>  
**Returns**: <code>Promise</code> - A promise that is resolved if the user data is loaded or rejected on error.  
**Example**  
```js
//load user data
$riffle.user.load().then(userLoaded, error);
```
<a name="$riffle.user.save"></a>
#### user.save() ⇒ <code>Promise</code>
Save the user data to Exis user storage. Both the private and public storage objects
on Exis will be overwritten with the contents of the local private and public storage objects.

**Kind**: static method of <code>[user](#$riffle.user)</code>  
**Returns**: <code>Promise</code> - A promise that is resolved if the user data is successfully saved or rejected on error.  
**Example**  
```js
//save user data
$riffle.user.save().then(userSaved, error);
```
<a name="$riffle.user.getPublicData"></a>
#### user.getPublicData([query]) ⇒ <code>Promise</code>
Load the public user objects from Storage. Accepts an optional MongoDB 
[query](https://docs.mongodb.org/manual/tutorial/query-documents/)  object to filter results.

**Kind**: static method of <code>[user](#$riffle.user)</code>  
**Returns**: <code>Promise</code> - A promise that is resolved with the user documents on success or rejected on error.  

| Param | Type | Description |
| --- | --- | --- |
| [query] | <code>object</code> | Optional MongoDB [query](https://docs.mongodb.org/manual/tutorial/query-documents/) |

<a name="$riffle.user.call"></a>
#### user.call(action, ...args) ⇒ <code>[RifflePromise](#RifflePromise)</code>
Call a function already registered to an action on this domain. If the domain object represents an domain like `xs.demo.user.app` the 
endpoint that is called to will look like `xs.demo.user.app/action`.

**Kind**: static method of <code>[user](#$riffle.user)</code>  
**Returns**: <code>[RifflePromise](#RifflePromise)</code> - Returns a regular promise but with an extra [want](#RifflePromise.want) function that can be used to specify the expected result type  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>string</code> | The action the function being called is registered under on the domain. |
| ...args | <code>\*</code> | The arguments to provide to the function being called. |

**Example**  
```js
//**Call w/optional type checking**
//call an action sum on with two numbers on our top level app domain. i.e. xs.demo.user.app/sum
var p = $riffle.call('sum', 1, 1);

//anyHandler will be called if the call is successful no matter what the result error1 will be called if there an error
p.then(anyHandler, error);

//numHandler will only be called if the result from the call is a number
//numError will be called if the response is not a number or any other error
p.want(Number).then(numHandler, numError);
```
<a name="$riffle.user.register"></a>
#### user.register(action, handler) ⇒ <code>Promise</code>
Register a function to handle calls made to action on this domain. If the domain object represents a domain like `xs.demo.user.app` the 
endpoint that the handler is registered to will look like `xs.demo.user.app/action`.

**Kind**: static method of <code>[user](#$riffle.user)</code>  
**Returns**: <code>Promise</code> - a promise that is resolved if the handler is successfully registered or rejected if there is an error.  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>string</code> | The action that the handler should be registered as under the domain. |
| handler | <code>function</code> | The function that will handle any calls made to the registered endpoint or a valid [want](#$riffle.want) function. |

**Example**  
```js
//**Registering a Procedure**
//register an action call hello on our top level app domain. i.e. xs.demo.user.app/hello
$riffle.register('hello', function(){
  console.log('hello');
});
```
<a name="$riffle.user.publish"></a>
#### user.publish(channel, ...args)
Publish data to any subscribers listening on a given channel on the domain. If the [domain](#RiffleDomain) represents a domain like `xs.demo.user.app` the 
endpoint that is published to will look like `xs.demo.user.app/channel`.

**Kind**: static method of <code>[user](#$riffle.user)</code>  

| Param | Type | Description |
| --- | --- | --- |
| channel | <code>string</code> | The channel the being published to on the domain. |
| ...args | <code>\*</code> | The arguments to publish to the channel. |

**Example**  
```js
//**Publishing**
//publish the string 'hello' to the `ping` channel on our top level app domain. i.e. `xs.demo.user.app/ping`
$riffle.publish('ping', 'hello');
```
<a name="$riffle.user.subscribe"></a>
#### user.subscribe(channel, handler) ⇒ <code>Promise</code>
Subscribe a function to handle publish events made to the channel on this domain. If the domain object represents an domain like `xs.demo.user.app` the 
endpoint that the handler is subscribed to will look like `xs.demo.user.app/channel`.

**Kind**: static method of <code>[user](#$riffle.user)</code>  
**Returns**: <code>Promise</code> - a promise that is resolved if the handler is successfully subscribed or rejected if there is an error.  

| Param | Type | Description |
| --- | --- | --- |
| channel | <code>string</code> | The channel that the handler should subscribe to under the domain. |
| handler | <code>function</code> | The function that will handle any publishes made to the registered endpoint or a valid [want](#$riffle.want) function. |

**Example**  
```js
//**Subscribing to an Event**
//subscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
$riffle.subscribe('hello', function(){
  console.log('Received hello event!');
});
```
<a name="$riffle.user.subscribeOnScope"></a>
#### user.subscribeOnScope(scope, channel, handler) ⇒ <code>Promise</code>
Creates a subscription via [subscribe](#RiffleDomain.subscribe) but binds it to the provided scope so that on destruction of the scope the handler is unsubscribed.

**Kind**: static method of <code>[user](#$riffle.user)</code>  
**Returns**: <code>Promise</code> - a promise that is resolved if the handler is successfully subscribed or rejected if there is an error.  

| Param | Type | Description |
| --- | --- | --- |
| scope | <code>object</code> | The $scope that the subscribe should be bound to. |
| channel | <code>string</code> | The channel that the handler should subscribe to under the domain. |
| handler | <code>function</code> | The function that will handle any publishes made to the registered endpoint or a valid [want](#$riffle.want) function. |

**Example**  
```js
//**Subscribing on a $scope**
//subscribe to events published to hello on our top level app domain and bind the subscription to $scope
//when $scope.$on('$destroy') is triggered the handler will be unsubscribed
$riffle.subscribeOnScope($scope, 'hello', function(){
  console.log('Received hello event!');
});
```
<a name="$riffle.user.unregister"></a>
#### user.unregister(action)
Unregister the handler for the specified action on this domain.

**Kind**: static method of <code>[user](#$riffle.user)</code>  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>string</code> | The action that you wish to unregister the handler from under the domain. |

**Example**  
```js
//**Unregister**
//unregister the 'getData' action handler on our top level app domain. i.e. xs.demo.user.app/getData
$riffle.unregister('getData');
```
<a name="$riffle.user.unsubscribe"></a>
#### user.unsubscribe(channel)
Unsubscribe all handlers subscribe to the channel on this domain.

**Kind**: static method of <code>[user](#$riffle.user)</code>  

| Param | Type | Description |
| --- | --- | --- |
| channel | <code>string</code> | The channel that you wish to unsubscribe handlers from under the domain. |

**Example**  
```js
//**Unsubscribe**
//unsubscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
$riffle.unsubscribe('hello');
```
<a name="$riffle.user.subdomain"></a>
#### user.subdomain(name) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
Create a subdomain from the current [domain](#RiffleDomain) object.

**Kind**: static method of <code>[user](#$riffle.user)</code>  
**Returns**: <code>[RiffleDomain](#RiffleDomain)</code> - A subdomain representing a domain with name appended to the parent domain. i.e. `xs.demo.user.app` => `xs.demo.user.app.subdomain`  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The name of the new subdomain. |

**Example**  
```js
//**Create a subdomain**
//if $riffle represents the domain xs.demo.user.app backend is a RiffleDomain that represents `xs.demo.user.app.backend`
var backend = $riffle.subdomain('backend');
```
<a name="$riffle.user.linkDomain"></a>
#### user.linkDomain(fullDomain) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
Create a new domain from the current [domain](#RiffleDomain) object that represents the domain specified by fullDomain.

**Kind**: static method of <code>[user](#$riffle.user)</code>  
**Returns**: <code>[RiffleDomain](#RiffleDomain)</code> - A [RiffleDomain](#RiffleDomain) representing a domain specified by the fullDomain argument  

| Param | Type | Description |
| --- | --- | --- |
| fullDomain | <code>string</code> | The full name of the new domain. |

**Example**  
```js
//**Link A Domain**
//create a new domain that represents xs.demo.partner.app
var anotherApp = $riffle.linkDomain('xs.demo.partner.app');
```
<a name="$riffle.user.join"></a>
#### user.join()
Attempts to create a connection to the Exis fabric using this domain. If successful a `$riffle.open` event will be broadcast throughout the app
to notify listening handlers that a successful connection was established.

**Kind**: static method of <code>[user](#$riffle.user)</code>  
**Example**  
```js
//**Joining a domain**
//attempt to join connect to Exis as the top level domain i.e. xs.demo.user.app
$riffle.join();

//if the join is successful this function will be triggered
$scope.$on('$riffle.open', function(){
  console.log('Connected!');
});
```
<a name="$riffle.user.leave"></a>
#### user.leave()
Unregister and unsubscribe anything in the domain and disconnect from Exis if this the the domain that [join](#RiffleDomain.join) was called on.
If the connection is closed a `$riffle.leave` event will be broadcast thoughout the app to notify listening handlers that the session has been closed.

**Kind**: static method of <code>[user](#$riffle.user)</code>  
**Example**  
```js
//**Logout/Disconnect**
//unregister/unsubscribe any handlers on the top level domain and close the connection if it this the the domain join was called on.
$riffle.leave();

//if the connection is closed this function will be triggered
$scope.$on('$riffle.leave', function(){
  console.log('Connection Closed!');
});
```
<a name="$riffle.user.getName"></a>
#### user.getName() ⇒ <code>string</code>
Get the string representation of the domain.

**Kind**: static method of <code>[user](#$riffle.user)</code>  
**Returns**: <code>string</code> - The string representation of the domain. i.e. `xs.demo.user.app`.  
**Example**  
```js
$riffle.getName(); //returns 'xs.demo.developer.app'
```
<a name="$riffle.user.username"></a>
#### user.username() ⇒ <code>string</code>
Returns the final portion of domain.

**Kind**: static method of <code>[user](#$riffle.user)</code>  
**Returns**: <code>string</code> - The final portion of the domain. i.e. `xs.demo.user.app.username` => `username`  
**Example**  
```js
$riffle.user.username(); //returns 'username'
```
<a name="ModelObject"></a>
## ModelObject
The ModelObject class is used to to wrap a custom JavaScript class and provides an API for interaction with
Model Object Storage via a [Storage](/docs/appliances/Storage) appliance. It can also be provided as an argument to
[want](#$riffle.want) to ensure objects recieved have the correct properties 
and are constructed with the correct prototype.

**Kind**: global typedef  
**Example**  
```js
//create a custom Person class
function Person(){
  this.first = String;
  this.last = String;
  this.age = Number;
}

Person.prototype.fullname = function(){
  return this.first + ' ' + this.last;
}
//create a ModelObect class representing our Person class
var person = $riffle.modelObject(Person);
```

* [ModelObject](#ModelObject)
    * _instance_
        * [.save()](#ModelObject+save) ⇒ <code>Promise</code>
        * [.delete()](#ModelObject+delete) ⇒ <code>Promise</code>
    * _static_
        * [.bind(domain, [storage], [collection])](#ModelObject.bind)
        * [.find(query)](#ModelObject.find) ⇒ <code>Promise</code>
        * [.find_one(query)](#ModelObject.find_one) ⇒ <code>Promise</code>

<a name="ModelObject+save"></a>
### modelObject.save() ⇒ <code>Promise</code>
Save the instance of the [ModelObject](#ModelObject) to the collection and [Storage](/docs/appliances/Storage) appliance it is bound to.

**Kind**: instance method of <code>[ModelObject](#ModelObject)</code>  
**Returns**: <code>Promise</code> - A promise that is resolved on success or rejected if there is an error.  
**Throws**:

- An error if the parent [ModelObject](#ModelObject) class isn't bound to a [Storage](/docs/appliances/Storage) appliance.

**Example**  
```js
//query for the first user named Nick Hyatt based on the person ModelObject created in the above example
person.find_one({first: 'Nick', last: 'Hyatt'}).then(funcition(nick){
  console.log(nick.fullname()); //prints 'Nick Hyatt'
  //change Nick's name to Steve
  nick.first = 'Steve';
  console.log(nick.fullname()); //prints 'Steve Hyatt'
  nick.save(); //Overwrites the old document 
});
```
<a name="ModelObject+delete"></a>
### modelObject.delete() ⇒ <code>Promise</code>
Delete the instance of  the [ModelObject](#ModelObject) from the collection and [Storage](/docs/appliances/Storage) appliance it is bound to.

**Kind**: instance method of <code>[ModelObject](#ModelObject)</code>  
**Returns**: <code>Promise</code> - A promise that is resolved on success or rejected if there is an error.  
**Throws**:

- An error if the parent [ModelObject](#ModelObject) class isn't bound to a [Storage](/docs/appliances/Storage) appliance.

**Example**  
```js
//query for the first user named Nick Hyatt based on the person ModelObject created in the above example
person.find_one({first: 'Nick', last: 'Hyatt'}).then(funcition(nick){
  nick.delete(); //removes document from storage
});
```
<a name="ModelObject.bind"></a>
### ModelObject.bind(domain, [storage], [collection])
Bind this instance of the ModelObject with a collection of ModelObjects in a [Storage](/docs/appliances/Storage) appliance.
Any instances constructed from the orignal [RiffleConstructor](#RiffleConstructor) or that are created as the result of either a
[want[reg/sub]](#$riffle.want) or a [want[call]](#RifflePromise.want) will have the [save](#ModelObject+save) and [delete](#ModelObject+delete) functions attached to the instance.

**Kind**: static method of <code>[ModelObject](#ModelObject)</code>  

| Param | Type | Description |
| --- | --- | --- |
| domain | <code>[RiffleDomain](#RiffleDomain)</code> | A [RiffleDomain](#RiffleDomain) object representing the attached [Storage](/docs/appliances/Storage) appliance or a domain currently connected to Exis. |
| [storage] | <code>string</code> | The fully qualified domain of the [Storage](/docs/appliances/Storage) appliance which to bind this ModelObject collection. If none is provided the `domain` object is assumed to be the [Storage](/docs/appliances/Storage) appliance. |
| [collection] | <code>string</code> | The name of the collection to bind the instance to. If none is provide the name of the class passed to [modelObject](#$riffle.modelObject) is used. |

**Example**  
```js
//create a custom Person class
function Person(){
  this.first = String;
  this.last = String;
  this.age = Number;
}

Person.prototype.fullname = function(){
  return this.first + ' ' + this.last;
}
//create a ModelObect class representing our Person class
var person = $riffle.modelObject(Person);

//create a subdomain representing a Storage applinance
var storage = $riffle.subdomain('Storage');

//bind the person ModelObject to the Storage appliance
person.bind(storage); //The collection will be named Person based on the class by default
```
<a name="ModelObject.find"></a>
### ModelObject.find(query) ⇒ <code>Promise</code>
Query the ModelObject collection in the bound [Storage](/docs/appliances/Storage) appliance for multiple documents matching the query.

**Kind**: static method of <code>[ModelObject](#ModelObject)</code>  
**Returns**: <code>Promise</code> - A promise which will be resovled with the matching objects on success or rejected on error.  
**Throws**:

- An error if the [ModelObject](#ModelObject) class isn't bound to a [Storage](/docs/appliances/Storage) appliance.


| Param | Type | Description |
| --- | --- | --- |
| query | <code>object</code> | A valid MongoDB [query](https://docs.mongodb.org/manual/tutorial/query-documents/) object. |

**Example**  
```js
//create a custom Person class
function Person(){
  this.first = String;
  this.last = String;
  this.age = Number;
}

Person.prototype.fullname = function(){
  return this.first + ' ' + this.last;
}
//create a ModelObect class representing our Person class
var person = $riffle.modelObject(Person);

//create a subdomain representing a Storage applinance
var storage = $riffle.subdomain('Storage');

//bind the person ModelObject to the Storage appliance
person.bind(storage); //The collection will be named Person based on the class by default

//query for all users named Nick
person.find({first: 'Nick'}).then(handleNicks);
```
<a name="ModelObject.find_one"></a>
### ModelObject.find_one(query) ⇒ <code>Promise</code>
Query the ModelObject collection in the bound [Storage](/docs/appliances/Storage) appliance for the first document matching the query.

**Kind**: static method of <code>[ModelObject](#ModelObject)</code>  
**Returns**: <code>Promise</code> - A promise which will be resovled with the matching object on success or rejected on error.  
**Throws**:

- An error if the [ModelObject](#ModelObject) class isn't bound to a [Storage](/docs/appliances/Storage) appliance.


| Param | Type | Description |
| --- | --- | --- |
| query | <code>object</code> | A valid MongoDB [query](https://docs.mongodb.org/manual/tutorial/query-documents/) object. |

**Example**  
```js
//create a custom Person class
function Person(){
  this.first = String;
  this.last = String;
  this.age = Number;
}

Person.prototype.fullname = function(){
  return this.first + ' ' + this.last;
}
//create a ModelObect class representing our Person class
var person = $riffle.modelObject(Person);

//create a subdomain representing a Storage applinance
var storage = $riffle.subdomain('Storage');

//bind the person ModelObject to the Storage appliance
person.bind(storage); //The collection will be named Person based on the class by default

//query for the first user named Nick
person.find_one({first: 'Nick'}).then(handleNick);
```
<a name="RiffleConstructor"></a>
## RiffleConstructor
A RiffleConstructor is simply a class constructor function with the expected property set to be the expected `Type`
This Constructor can be used to create a [ModelObject](#ModelObject) via the [modelObject](#$riffle.modelObject) function and used for as an expected
type for [want](#$riffle.want).

**Kind**: global typedef  
**Example**  
```js
//A valid RiffleConstructor for the Person class with attached prototype
function Person(){
  this.first = String;
  this.last = String;
  this.age = Number;
}

Person.prototype.fullname = function(){
  return this.first + ' ' + this.last;
}
```
<a name="RiffleDomain"></a>
## RiffleDomain
A RiffleDomain is an object which represents a specific [domain](/docs/riffle/Domain) on Exis and
provides an API for performing actions such as [register](#RiffleDomain.register) and [call](#RiffleDomain.call) on behalf of the [domain](/docs/riffle/Domain).
The `$riffle` service is itself the top level domain of our application and represents a domain like `xs.demo.user.app`. Creating subdomains from the `$riffle` service
would give us domain objects representing a domain like `xs.demo.user.app.subdomain`. Creating subdomains from any `RiffleDomain` always creates a new domain object
with its namespace one level lower than it's parent.

**Kind**: global typedef  
**Example**  
```js
//construct a valid subdomain from $riffle service
var backend = $riffle.subdomain('backend');

//call a function that our backend domain has registered as part of its API
backend.call('getData').then(handler);
```

* [RiffleDomain](#RiffleDomain)
    * [.getName()](#RiffleDomain.getName) ⇒ <code>string</code>
    * [.username()](#RiffleDomain.username) ⇒ <code>string</code>
    * [.register(action, handler)](#RiffleDomain.register) ⇒ <code>Promise</code>
    * [.call(action, ...args)](#RiffleDomain.call) ⇒ <code>[RifflePromise](#RifflePromise)</code>
    * [.publish(channel, ...args)](#RiffleDomain.publish)
    * [.subscribe(channel, handler)](#RiffleDomain.subscribe) ⇒ <code>Promise</code>
    * [.subscribeOnScope(scope, channel, handler)](#RiffleDomain.subscribeOnScope) ⇒ <code>Promise</code>
    * [.unsubscribe(channel)](#RiffleDomain.unsubscribe)
    * [.unregister(action)](#RiffleDomain.unregister)
    * [.subdomain(name)](#RiffleDomain.subdomain) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
    * [.linkDomain(fullDomain)](#RiffleDomain.linkDomain) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
    * [.join()](#RiffleDomain.join)
    * [.leave()](#RiffleDomain.leave)

<a name="RiffleDomain.getName"></a>
### RiffleDomain.getName() ⇒ <code>string</code>
Get the string representation of the domain.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Returns**: <code>string</code> - The string representation of the domain. i.e. `xs.demo.user.app`.  
**Example**  
```js
$riffle.getName(); //returns 'xs.demo.developer.app'
```
<a name="RiffleDomain.username"></a>
### RiffleDomain.username() ⇒ <code>string</code>
Returns the final portion of domain.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Returns**: <code>string</code> - The final portion of the domain. i.e. `xs.demo.user.app.username` => `username`  
**Example**  
```js
$riffle.user.username(); //returns 'username'
```
<a name="RiffleDomain.register"></a>
### RiffleDomain.register(action, handler) ⇒ <code>Promise</code>
Register a function to handle calls made to action on this domain. If the domain object represents a domain like `xs.demo.user.app` the 
endpoint that the handler is registered to will look like `xs.demo.user.app/action`.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Returns**: <code>Promise</code> - a promise that is resolved if the handler is successfully registered or rejected if there is an error.  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>string</code> | The action that the handler should be registered as under the domain. |
| handler | <code>function</code> | The function that will handle any calls made to the registered endpoint or a valid [want](#$riffle.want) function. |

**Example**  
```js
//**Registering a Procedure**
//register an action call hello on our top level app domain. i.e. xs.demo.user.app/hello
$riffle.register('hello', function(){
  console.log('hello');
});
```
<a name="RiffleDomain.call"></a>
### RiffleDomain.call(action, ...args) ⇒ <code>[RifflePromise](#RifflePromise)</code>
Call a function already registered to an action on this domain. If the domain object represents an domain like `xs.demo.user.app` the 
endpoint that is called to will look like `xs.demo.user.app/action`.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Returns**: <code>[RifflePromise](#RifflePromise)</code> - Returns a regular promise but with an extra [want](#RifflePromise.want) function that can be used to specify the expected result type  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>string</code> | The action the function being called is registered under on the domain. |
| ...args | <code>\*</code> | The arguments to provide to the function being called. |

**Example**  
```js
//**Call w/optional type checking**
//call an action sum on with two numbers on our top level app domain. i.e. xs.demo.user.app/sum
var p = $riffle.call('sum', 1, 1);

//anyHandler will be called if the call is successful no matter what the result error1 will be called if there an error
p.then(anyHandler, error);

//numHandler will only be called if the result from the call is a number
//numError will be called if the response is not a number or any other error
p.want(Number).then(numHandler, numError);
```
<a name="RiffleDomain.publish"></a>
### RiffleDomain.publish(channel, ...args)
Publish data to any subscribers listening on a given channel on the domain. If the [domain](#RiffleDomain) represents a domain like `xs.demo.user.app` the 
endpoint that is published to will look like `xs.demo.user.app/channel`.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  

| Param | Type | Description |
| --- | --- | --- |
| channel | <code>string</code> | The channel the being published to on the domain. |
| ...args | <code>\*</code> | The arguments to publish to the channel. |

**Example**  
```js
//**Publishing**
//publish the string 'hello' to the `ping` channel on our top level app domain. i.e. `xs.demo.user.app/ping`
$riffle.publish('ping', 'hello');
```
<a name="RiffleDomain.subscribe"></a>
### RiffleDomain.subscribe(channel, handler) ⇒ <code>Promise</code>
Subscribe a function to handle publish events made to the channel on this domain. If the domain object represents an domain like `xs.demo.user.app` the 
endpoint that the handler is subscribed to will look like `xs.demo.user.app/channel`.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Returns**: <code>Promise</code> - a promise that is resolved if the handler is successfully subscribed or rejected if there is an error.  

| Param | Type | Description |
| --- | --- | --- |
| channel | <code>string</code> | The channel that the handler should subscribe to under the domain. |
| handler | <code>function</code> | The function that will handle any publishes made to the registered endpoint or a valid [want](#$riffle.want) function. |

**Example**  
```js
//**Subscribing to an Event**
//subscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
$riffle.subscribe('hello', function(){
  console.log('Received hello event!');
});
```
<a name="RiffleDomain.subscribeOnScope"></a>
### RiffleDomain.subscribeOnScope(scope, channel, handler) ⇒ <code>Promise</code>
Creates a subscription via [subscribe](#RiffleDomain.subscribe) but binds it to the provided scope so that on destruction of the scope the handler is unsubscribed.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Returns**: <code>Promise</code> - a promise that is resolved if the handler is successfully subscribed or rejected if there is an error.  

| Param | Type | Description |
| --- | --- | --- |
| scope | <code>object</code> | The $scope that the subscribe should be bound to. |
| channel | <code>string</code> | The channel that the handler should subscribe to under the domain. |
| handler | <code>function</code> | The function that will handle any publishes made to the registered endpoint or a valid [want](#$riffle.want) function. |

**Example**  
```js
//**Subscribing on a $scope**
//subscribe to events published to hello on our top level app domain and bind the subscription to $scope
//when $scope.$on('$destroy') is triggered the handler will be unsubscribed
$riffle.subscribeOnScope($scope, 'hello', function(){
  console.log('Received hello event!');
});
```
<a name="RiffleDomain.unsubscribe"></a>
### RiffleDomain.unsubscribe(channel)
Unsubscribe all handlers subscribe to the channel on this domain.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  

| Param | Type | Description |
| --- | --- | --- |
| channel | <code>string</code> | The channel that you wish to unsubscribe handlers from under the domain. |

**Example**  
```js
//**Unsubscribe**
//unsubscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
$riffle.unsubscribe('hello');
```
<a name="RiffleDomain.unregister"></a>
### RiffleDomain.unregister(action)
Unregister the handler for the specified action on this domain.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  

| Param | Type | Description |
| --- | --- | --- |
| action | <code>string</code> | The action that you wish to unregister the handler from under the domain. |

**Example**  
```js
//**Unregister**
//unregister the 'getData' action handler on our top level app domain. i.e. xs.demo.user.app/getData
$riffle.unregister('getData');
```
<a name="RiffleDomain.subdomain"></a>
### RiffleDomain.subdomain(name) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
Create a subdomain from the current [domain](#RiffleDomain) object.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Returns**: <code>[RiffleDomain](#RiffleDomain)</code> - A subdomain representing a domain with name appended to the parent domain. i.e. `xs.demo.user.app` => `xs.demo.user.app.subdomain`  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The name of the new subdomain. |

**Example**  
```js
//**Create a subdomain**
//if $riffle represents the domain xs.demo.user.app backend is a RiffleDomain that represents `xs.demo.user.app.backend`
var backend = $riffle.subdomain('backend');
```
<a name="RiffleDomain.linkDomain"></a>
### RiffleDomain.linkDomain(fullDomain) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
Create a new domain from the current [domain](#RiffleDomain) object that represents the domain specified by fullDomain.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Returns**: <code>[RiffleDomain](#RiffleDomain)</code> - A [RiffleDomain](#RiffleDomain) representing a domain specified by the fullDomain argument  

| Param | Type | Description |
| --- | --- | --- |
| fullDomain | <code>string</code> | The full name of the new domain. |

**Example**  
```js
//**Link A Domain**
//create a new domain that represents xs.demo.partner.app
var anotherApp = $riffle.linkDomain('xs.demo.partner.app');
```
<a name="RiffleDomain.join"></a>
### RiffleDomain.join()
Attempts to create a connection to the Exis fabric using this domain. If successful a `$riffle.open` event will be broadcast throughout the app
to notify listening handlers that a successful connection was established.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Example**  
```js
//**Joining a domain**
//attempt to join connect to Exis as the top level domain i.e. xs.demo.user.app
$riffle.join();

//if the join is successful this function will be triggered
$scope.$on('$riffle.open', function(){
  console.log('Connected!');
});
```
<a name="RiffleDomain.leave"></a>
### RiffleDomain.leave()
Unregister and unsubscribe anything in the domain and disconnect from Exis if this the the domain that [join](#RiffleDomain.join) was called on.
If the connection is closed a `$riffle.leave` event will be broadcast thoughout the app to notify listening handlers that the session has been closed.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Example**  
```js
//**Logout/Disconnect**
//unregister/unsubscribe any handlers on the top level domain and close the connection if it this the the domain join was called on.
$riffle.leave();

//if the connection is closed this function will be triggered
$scope.$on('$riffle.leave', function(){
  console.log('Connection Closed!');
});
```
<a name="RifflePromise"></a>
## RifflePromise
A RifflePromise is a regular Promise object that simply implements an extra [want](#RifflePromise.want) function which specifies what the
expected result of a [call](#RiffleDomain.call) should be.

**Kind**: global typedef  
**Example**  
```js
//call a function that and only execute our handler if the result is a string
$riffle.call('getData').want(String).then(handler);
```
<a name="RifflePromise.want"></a>
### RifflePromise.want(...types) ⇒ <code>Promise</code>
A function which returns a promise that is resolved if the return of the call matches the types provided or is rejected otherwise.

**Kind**: static method of <code>[RifflePromise](#RifflePromise)</code>  
**Returns**: <code>Promise</code> - Returns a regular promise that is resolved if the call succeeds an the return is of the correct type or is rejected otherwise.  

| Param | Type | Description |
| --- | --- | --- |
| ...types | <code>Type</code> | The types of expected return values. Valid types are `String`, `Number`, `[Type]`(an Array with elements of `Type`), `{key1: Type, key2: Type}`(An object with keys `key1` and `key2` each of `Type`), or `ModelObject`(a valid [ModelObject](#ModelObject)). |

**Example**  
```js
//**Call type checking**
//call a function that and only execute our handler if the result is a string
$riffle.call('getData').want(String).then(handler);
```
<a name="Auth"></a>
## Auth
The Auth class provides an API for interacting with an [Auth](/docs/appliances/Auth) Appliance

**Kind**: global typedef  
**See**: [here](/docs/appliances/Auth) for documentation.  
**Example**  
```js
**Query Auth Users**
//create a Auth instance from the domain
var auth = $riffle.xsAuth();

//get data about users(email, name, etc.)
auth.get_users().then(handler, error);
```

* [Auth](#Auth)
    * [.delete_custom_token()](#Auth.delete_custom_token)
    * [.gen_custom_token()](#Auth.gen_custom_token)
    * [.get_custom_token()](#Auth.get_custom_token)
    * [.get_private_data()](#Auth.get_private_data)
    * [.get_public_data()](#Auth.get_public_data)
    * [.get_users()](#Auth.get_users)
    * [.get_user_data()](#Auth.get_user_data)
    * [.list_custom_tokens()](#Auth.list_custom_tokens)
    * [.save_user_data()](#Auth.save_user_data)
    * [.user_count()](#Auth.user_count)

<a name="Auth.delete_custom_token"></a>
### Auth.delete_custom_token()
**Kind**: static method of <code>[Auth](#Auth)</code>  
**See**: [here](/docs/appliances/Auth#delete_custom_token) for documentation.  
**Example**  
```js
auth.delete_custom_token(...args).then(success, error);
```
<a name="Auth.gen_custom_token"></a>
### Auth.gen_custom_token()
**Kind**: static method of <code>[Auth](#Auth)</code>  
**See**: [here](/docs/appliances/Auth#gen_custom_token) for documentation.  
**Example**  
```js
auth.gen_custom_token(...args).then(success, error);
```
<a name="Auth.get_custom_token"></a>
### Auth.get_custom_token()
**Kind**: static method of <code>[Auth](#Auth)</code>  
**See**: [here](/docs/appliances/Auth#get_custom_token) for documentation.  
**Example**  
```js
auth.get_custom_token(...args).then(success, error);
```
<a name="Auth.get_private_data"></a>
### Auth.get_private_data()
**Kind**: static method of <code>[Auth](#Auth)</code>  
**See**: [here](/docs/appliances/Auth#get_private_data) for documentation.  
**Example**  
```js
auth.get_private_data(...args).then(success, error);
```
<a name="Auth.get_public_data"></a>
### Auth.get_public_data()
**Kind**: static method of <code>[Auth](#Auth)</code>  
**See**: [here](/docs/appliances/Auth#get_public_data) for documentation.  
**Example**  
```js
auth.get_public_data(...args).then(success, error);
```
<a name="Auth.get_users"></a>
### Auth.get_users()
**Kind**: static method of <code>[Auth](#Auth)</code>  
**See**: [here](/docs/appliances/Auth#get_users) for documentation.  
**Example**  
```js
auth.get_users(...args).then(success, error);
```
<a name="Auth.get_user_data"></a>
### Auth.get_user_data()
**Kind**: static method of <code>[Auth](#Auth)</code>  
**See**: [here](/docs/appliances/Auth#get_user_data) for documentation.  
**Example**  
```js
auth.get_user_data(...args).then(success, error);
```
<a name="Auth.list_custom_tokens"></a>
### Auth.list_custom_tokens()
**Kind**: static method of <code>[Auth](#Auth)</code>  
**See**: [here](/docs/appliances/Auth#list_custom_tokens) for documentation.  
**Example**  
```js
auth.list_custom_tokens(...args).then(success, error);
```
<a name="Auth.save_user_data"></a>
### Auth.save_user_data()
**Kind**: static method of <code>[Auth](#Auth)</code>  
**See**: [here](/docs/appliances/Auth#save_user_data) for documentation.  
**Example**  
```js
auth.save_user_data(...args).then(success, error);
```
<a name="Auth.user_count"></a>
### Auth.user_count()
**Kind**: static method of <code>[Auth](#Auth)</code>  
**See**: [here](/docs/appliances/Auth#user_count) for documentation.  
**Example**  
```js
auth.user_count(...args).then(success, error);
```
<a name="Bouncer"></a>
## Bouncer
The Bouncer class provides an API for interacting with the [Bouncer](/docs/appliances/Bouncer) Appliance

**Kind**: global typedef  
**See**: [here](/docs/appliances/Bouncer) for documentation.  
**Example**  
```js
//create a Bouncer instance from the domain
var bouncer = $riffle.xsBouncer();

//create a static role
bouncer.addStaticRole('admin', app.getName());
```

* [Bouncer](#Bouncer)
    * [.addDevModeDomain()](#Bouncer.addDevModeDomain)
    * [.addDynamicRole()](#Bouncer.addDynamicRole)
    * [.addSpecialAgent()](#Bouncer.addSpecialAgent)
    * [.addStaticRole()](#Bouncer.addStaticRole)
    * [.assignDynamicRole()](#Bouncer.assignDynamicRole)
    * [.assignRole()](#Bouncer.assignRole)
    * [.checkPerm()](#Bouncer.checkPerm)
    * [.delDynamicRole()](#Bouncer.delDynamicRole)
    * [.destroyRole()](#Bouncer.destroyRole)
    * [.inDevModeStatus()](#Bouncer.inDevModeStatus)
    * [.listMembers()](#Bouncer.listMembers)
    * [.listRoles()](#Bouncer.listRoles)
    * [.listSpecialAgents()](#Bouncer.listSpecialAgents)
    * [.newDynamicRole()](#Bouncer.newDynamicRole)
    * [.removeApp()](#Bouncer.removeApp)
    * [.removeDevModeDomain()](#Bouncer.removeDevModeDomain)
    * [.removeSpecialAgent()](#Bouncer.removeSpecialAgent)
    * [.revokeDynamicRole()](#Bouncer.revokeDynamicRole)
    * [.revokePerm()](#Bouncer.revokePerm)
    * [.revokeRole()](#Bouncer.revokeRole)
    * [.setPerm()](#Bouncer.setPerm)

<a name="Bouncer.addDevModeDomain"></a>
### Bouncer.addDevModeDomain()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#addDevModeDomain) for documentation.  
**Example**  
```js
bouncer.addDevModeDomain(...args).then(success, error);
```
<a name="Bouncer.addDynamicRole"></a>
### Bouncer.addDynamicRole()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#addDynamicRole) for documentation.  
**Example**  
```js
bouncer.addDynamicRole(...args).then(success, error);
```
<a name="Bouncer.addSpecialAgent"></a>
### Bouncer.addSpecialAgent()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#addSpecialAgent) for documentation.  
**Example**  
```js
bouncer.addSpecialAgent(...args).then(success, error);
```
<a name="Bouncer.addStaticRole"></a>
### Bouncer.addStaticRole()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#addStaticRole) for documentation.  
**Example**  
```js
bouncer.addStaticRole(...args).then(success, error);
```
<a name="Bouncer.assignDynamicRole"></a>
### Bouncer.assignDynamicRole()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#assignDynamicRole) for documentation.  
**Example**  
```js
bouncer.assignDynamicRole(...args).then(success, error);
```
<a name="Bouncer.assignRole"></a>
### Bouncer.assignRole()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#assignRole) for documentation.  
**Example**  
```js
bouncer.assignRole(...args).then(success, error);
```
<a name="Bouncer.checkPerm"></a>
### Bouncer.checkPerm()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#checkPerm) for documentation.  
**Example**  
```js
bouncer.checkPerm(...args).then(success, error);
```
<a name="Bouncer.delDynamicRole"></a>
### Bouncer.delDynamicRole()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#delDynamicRole) for documentation.  
**Example**  
```js
bouncer.delDynamicRole(...args).then(success, error);
```
<a name="Bouncer.destroyRole"></a>
### Bouncer.destroyRole()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#destroyRole) for documentation.  
**Example**  
```js
bouncer.destroyRole(...args).then(success, error);
```
<a name="Bouncer.inDevModeStatus"></a>
### Bouncer.inDevModeStatus()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#inDevModeStatus) for documentation.  
**Example**  
```js
bouncer.inDevModeStatus(...args).then(success, error);
```
<a name="Bouncer.listMembers"></a>
### Bouncer.listMembers()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#listMembers) for documentation.  
**Example**  
```js
bouncer.listMembers(...args).then(success, error);
```
<a name="Bouncer.listRoles"></a>
### Bouncer.listRoles()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#listRoles) for documentation.  
**Example**  
```js
bouncer.listRoles(...args).then(success, error);
```
<a name="Bouncer.listSpecialAgents"></a>
### Bouncer.listSpecialAgents()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#listSpecialAgents) for documentation.  
**Example**  
```js
bouncer.listSpecialAgents(...args).then(success, error);
```
<a name="Bouncer.newDynamicRole"></a>
### Bouncer.newDynamicRole()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#newDynamicRole) for documentation.  
**Example**  
```js
bouncer.newDynamicRole(...args).then(success, error);
```
<a name="Bouncer.removeApp"></a>
### Bouncer.removeApp()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#removeApp) for documentation.  
**Example**  
```js
bouncer.removeApp(...args).then(success, error);
```
<a name="Bouncer.removeDevModeDomain"></a>
### Bouncer.removeDevModeDomain()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#removeDevModeDomain) for documentation.  
**Example**  
```js
bouncer.removeDevModeDomain(...args).then(success, error);
```
<a name="Bouncer.removeSpecialAgent"></a>
### Bouncer.removeSpecialAgent()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#removeSpecialAgent) for documentation.  
**Example**  
```js
bouncer.removeSpecialAgent(...args).then(success, error);
```
<a name="Bouncer.revokeDynamicRole"></a>
### Bouncer.revokeDynamicRole()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#revokeDynamicRole) for documentation.  
**Example**  
```js
bouncer.revokeDynamicRole(...args).then(success, error);
```
<a name="Bouncer.revokePerm"></a>
### Bouncer.revokePerm()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#revokePerm) for documentation.  
**Example**  
```js
bouncer.revokePerm(...args).then(success, error);
```
<a name="Bouncer.revokeRole"></a>
### Bouncer.revokeRole()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#revokeRole) for documentation.  
**Example**  
```js
bouncer.revokeRole(...args).then(success, error);
```
<a name="Bouncer.setPerm"></a>
### Bouncer.setPerm()
**Kind**: static method of <code>[Bouncer](#Bouncer)</code>  
**See**: [here](/docs/appliances/Bouncer#setPerm) for documentation.  
**Example**  
```js
bouncer.setPerm(...args).then(success, error);
```
<a name="Container"></a>
## Container
The Container class provides an API for interacting with an [Container](/docs/appliances/Container) Appliance

**Kind**: global typedef  
**See**: [here](/docs/appliances/Container) for documentation.  
**Example**  
```js
//create a Container instance from the domain
var cntr = $riffle.xsContainers();

//get data about users(email, name, etc.)
cntr.get_users().then(handler, error);
```

* [Container](#Container)
    * [.build()](#Container.build)
    * [.create()](#Container.create)
    * [.list()](#Container.list)
    * [.images()](#Container.images)
    * [.remove()](#Container.remove)
    * [.removeImage()](#Container.removeImage)
    * [.updateImage()](#Container.updateImage)
    * [.image(name)](#Container.image)
    * [.inspect(name)](#Container.inspect)
    * [.logs(name)](#Container.logs)
    * [.restart(name)](#Container.restart)
    * [.start(name)](#Container.start)
    * [.stop(name)](#Container.stop)
    * [.top(name)](#Container.top)

<a name="Container.build"></a>
### Container.build()
**Kind**: static method of <code>[Container](#Container)</code>  
**See**: [here](/docs/appliances/Container#build) for documentation.  
**Example**  
```js
container.build(...args).then(success, error);
```
<a name="Container.create"></a>
### Container.create()
**Kind**: static method of <code>[Container](#Container)</code>  
**See**: [here](/docs/appliances/Container#create) for documentation.  
**Example**  
```js
container.create(...args).then(success, error);
```
<a name="Container.list"></a>
### Container.list()
**Kind**: static method of <code>[Container](#Container)</code>  
**See**: [here](/docs/appliances/Container#list) for documentation.  
**Example**  
```js
container.list(...args).then(success, error);
```
<a name="Container.images"></a>
### Container.images()
**Kind**: static method of <code>[Container](#Container)</code>  
**See**: [here](/docs/appliances/Container#images) for documentation.  
**Example**  
```js
container.images(...args).then(success, error);
```
<a name="Container.remove"></a>
### Container.remove()
**Kind**: static method of <code>[Container](#Container)</code>  
**See**: [here](/docs/appliances/Container#remove) for documentation.  
**Example**  
```js
container.remove(...args).then(success, error);
```
<a name="Container.removeImage"></a>
### Container.removeImage()
**Kind**: static method of <code>[Container](#Container)</code>  
**See**: [here](/docs/appliances/Container#removeImage) for documentation.  
**Example**  
```js
container.removeImage(...args).then(success, error);
```
<a name="Container.updateImage"></a>
### Container.updateImage()
**Kind**: static method of <code>[Container](#Container)</code>  
**See**: [here](/docs/appliances/Container#updateImage) for documentation.  
**Example**  
```js
container.updateImage(...args).then(success, error);
```
<a name="Container.image"></a>
### Container.image(name)
Retrieve details about the image the container was created from.

**Kind**: static method of <code>[Container](#Container)</code>  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The name of the container. |

**Example**  
```js
container.image(name).then(success, error);
```
<a name="Container.inspect"></a>
### Container.inspect(name)
Retrieve details about the container.

**Kind**: static method of <code>[Container](#Container)</code>  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The name of the container. |

**Example**  
```js
container.inspect(name).then(success, error);
```
<a name="Container.logs"></a>
### Container.logs(name)
Fetch the logs for the container.

**Kind**: static method of <code>[Container](#Container)</code>  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The name of the container. |

**Example**  
```js
container.logs(name).then(success, error);
```
<a name="Container.restart"></a>
### Container.restart(name)
Restart the container.

**Kind**: static method of <code>[Container](#Container)</code>  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The name of the container. |

**Example**  
```js
container.restart(name).then(success, error);
```
<a name="Container.start"></a>
### Container.start(name)
Start the container.

**Kind**: static method of <code>[Container](#Container)</code>  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The name of the container. |

**Example**  
```js
container.start(name).then(success, error);
```
<a name="Container.stop"></a>
### Container.stop(name)
Stop the running container.

**Kind**: static method of <code>[Container](#Container)</code>  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The name of the container. |

**Example**  
```js
container.stop(name).then(success, error);
```
<a name="Container.top"></a>
### Container.top(name)
See details about the running container.

**Kind**: static method of <code>[Container](#Container)</code>  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The name of the container. |

**Example**  
```js
container.top(name).then(success, error);
```
<a name="FileStorage"></a>
## FileStorage
The FileStorage class provides an API for interacting with Exis' Cloud FileStorage system

**Kind**: global typedef  
**Example**  
```js
**Listing files in FileStorage Service**
//create a FileStorage instance from the domain
var filestorage = $riffle.xsFileStorage();

//get info about the contents of the directory
filestorage.listUserCollection('photos').then(handler, error);
//handler recieves an object describing the contents of the form below
{
  files: [
    {
      modified: string, //ISO timestamp last modified for the file
      name: string, //The filename as assigned by dev
      path: string, //The path of the file
      url: string, //A url that can be used to get the file
    }, ...
  ],
  collections: [
    {
      name: string, //The name of the collection
      path: string, //The path at which the file resides
    }
  ]
}
```

* [FileStorage](#FileStorage)
    * [.uploadUserFile(details)](#FileStorage.uploadUserFile)
    * [.uploadFile(details)](#FileStorage.uploadFile)
    * [.deleteUserFile(name, collection)](#FileStorage.deleteUserFile) ⇒ <code>boolean</code>
    * [.deleteFile(path)](#FileStorage.deleteFile) ⇒ <code>boolean</code>
    * [.deleteUserCollection(collection)](#FileStorage.deleteUserCollection) ⇒ <code>boolean</code>
    * [.deleteCollection(collection)](#FileStorage.deleteCollection) ⇒ <code>boolean</code>
    * [.getUserFile(name, collecion)](#FileStorage.getUserFile) ⇒ <code>string</code>
    * [.getFile(path)](#FileStorage.getFile) ⇒ <code>string</code>
    * [.listUserCollection(path, [recursive])](#FileStorage.listUserCollection) ⇒ <code>object</code>
    * [.listCollection(path, [recursive])](#FileStorage.listCollection) ⇒ <code>object</code>

<a name="FileStorage.uploadUserFile"></a>
### FileStorage.uploadUserFile(details)
Upload a file to the user's collection. This function only works for users or Containers of a registered app.

**Kind**: static method of <code>[FileStorage](#FileStorage)</code>  

| Param | Type | Description |
| --- | --- | --- |
| details | <code>object</code> | An object containing the details and the file to upload. |
| details.file | <code>File</code> | The File object. |
| details.name | <code>string</code> | The name to save the file to when it is uploaded. |
| [user.collection] | <code>string</code> | The collection or path to store the file to. Defaults to 'uploads'. |

**Example**  
```js
//create a FileStorage instance using the domain
var filestorage = $riffle.xsFileStorage();

//upload the user's profile.jpg to their 'photos' collection in Cloud FileStorage
//file is a File object
filestorage.uploadFile({file: file, name: 'profile.jpg', collection: 'photos'}).then(success, error, progress); //progess will recieve calls during upload with the percentage complete.
```
<a name="FileStorage.uploadFile"></a>
### FileStorage.uploadFile(details)
Upload a file to a registered app's FileStorage. This function only works for developers.

**Kind**: static method of <code>[FileStorage](#FileStorage)</code>  

| Param | Type | Description |
| --- | --- | --- |
| details | <code>object</code> | An object containing the details and the file to upload. |
| details.file | <code>File</code> | The File object. |
| details.path | <code>string</code> | The name to save the file to when it is uploaded starting with the app i.e. myapp/public/photo.jpg. |

**Example**  
```js
//create a FileStorage instance using the domain
var filestorage = $riffle.xsFileStorage();

//upload a file to the location of path in myapp's Cloud FileStorage
//file is a File object
filestorage.uploadFile({file: file, path: 'myapp/myfile.txt'}).then(success, error, progress); //progess will recieve calls during upload with the percentage complete.
```
<a name="FileStorage.deleteUserFile"></a>
### FileStorage.deleteUserFile(name, collection) ⇒ <code>boolean</code>
Delete a file from the user's collection. This function only works for users or Containers of a registered app.
Deleted files may take up to 15 minutes to become unavailable at the url.

**Kind**: static method of <code>[FileStorage](#FileStorage)</code>  
**Returns**: <code>boolean</code> - - True on success.  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The name of the file to delete. |
| collection | <code>string</code> | The collection or path the file is saved to. |

**Example**  
```js
filestorage.deleteUserFile('profile.jpg', 'uploads').then(suc, err);
```
<a name="FileStorage.deleteFile"></a>
### FileStorage.deleteFile(path) ⇒ <code>boolean</code>
Delete a file located anywhere in an app's storage. This function only works for developers.
Deleted files may take up to 15 minutes to become unavailable at the url.

**Kind**: static method of <code>[FileStorage](#FileStorage)</code>  
**Returns**: <code>boolean</code> - - True on success.  

| Param | Type | Description |
| --- | --- | --- |
| path | <code>string</code> | The path to the file starting with the app. i.e. app/logo.jpg |

**Example**  
```js
filestorage.deleteFile('app/banneduser/profile.jpg').then(suc, err);
```
<a name="FileStorage.deleteUserCollection"></a>
### FileStorage.deleteUserCollection(collection) ⇒ <code>boolean</code>
Delete a collection and it's contents  from the user's storage. This function only works for users or Containers of a registered app.
Deleted files may take up to 15 minutes to become unavailable at the url.

**Kind**: static method of <code>[FileStorage](#FileStorage)</code>  
**Returns**: <code>boolean</code> - - True on success.  

| Param | Type | Description |
| --- | --- | --- |
| collection | <code>string</code> | The collection or path to delete. |

**Example**  
```js
filestorage.deleteUserCollection('photos/unflattering').then(suc, err);
```
<a name="FileStorage.deleteCollection"></a>
### FileStorage.deleteCollection(collection) ⇒ <code>boolean</code>
Delete a collection and it's contents from storage anywhere in an app. This function only works for developers.
Deleted files may take up to 15 minutes to become unavailable at the url.

**Kind**: static method of <code>[FileStorage](#FileStorage)</code>  
**Returns**: <code>boolean</code> - - True on success.  

| Param | Type | Description |
| --- | --- | --- |
| collection | <code>string</code> | The collection or path to delete starting with the app. i.e. app/path/to/collection |

**Example**  
```js
filestorage.deleteCollection('app/photos/old').then(suc, err);
```
<a name="FileStorage.getUserFile"></a>
### FileStorage.getUserFile(name, collecion) ⇒ <code>string</code>
Get the url for a file in the user's storage. This function only works for users or Containers of a registered app.

**Kind**: static method of <code>[FileStorage](#FileStorage)</code>  
**Returns**: <code>string</code> - url - The url for the file.  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The name of the file. |
| collecion | <code>string</code> | The collection or path where the file is located. Defaults to 'uploads'. |

**Example**  
```js
filestorage.getUserFile('me.jpg').then(suc, err);
```
<a name="FileStorage.getFile"></a>
### FileStorage.getFile(path) ⇒ <code>string</code>
Get the url for a file in an app's FileStorage. This function works for all subdomains of a registered app.
Developer's must specify the app as the first part of the path.

**Kind**: static method of <code>[FileStorage](#FileStorage)</code>  
**Returns**: <code>string</code> - url - The url for the file.  

| Param | Type | Description |
| --- | --- | --- |
| path | <code>string</code> | The collection or path where the file is located with the file at the end. i.e. public/logo.jpg (user) or myapp/public/logo.jpg (developer) |

**Example**  
```js
filestorage.getFile('public/logo.jpg').then(suc, err);
```
<a name="FileStorage.listUserCollection"></a>
### FileStorage.listUserCollection(path, [recursive]) ⇒ <code>object</code>
Get details about the files and subcollections for the path. This function only works for users or Containers of a registered app.

**Kind**: static method of <code>[FileStorage](#FileStorage)</code>  
**Returns**: <code>object</code> - - An object describing the contents of the path.  

| Param | Type | Description |
| --- | --- | --- |
| path | <code>string</code> | The collection or path to list the contents of. |
| [recursive] | <code>boolean</code> | If true list all files in subcollections of this path as well. Defaults to false. |

**Example**  
```js
filestorage.listUserCollection('photos').then(suc, err);
//suc recieves an object describing the contents of the form below
{
  files: [
    {
      modified: string, //ISO timestamp last modified for the file
      name: string, //The filename as assigned by dev
      path: string, //The path of the file
      url: string, //A url that can be used to get the file
    }, ...
  ],
  collections: [
    {
      name: string, //The name of the collection
      path: string, //The path at which the file resides
    }
  ]
}
```
<a name="FileStorage.listCollection"></a>
### FileStorage.listCollection(path, [recursive]) ⇒ <code>object</code>
Get details about the files and subcollections for the path anywhere in an app. This function only works for developers.

**Kind**: static method of <code>[FileStorage](#FileStorage)</code>  
**Returns**: <code>object</code> - - An object describing the contents of the path.  

| Param | Type | Description |
| --- | --- | --- |
| path | <code>string</code> | The collection or path to list the contents of starting with the app. i.e. app/collection |
| [recursive] | <code>boolean</code> | If true list all files in subcollections of this path as well. Defaults to false. |

**Example**  
```js
filestorage.listCollection('app/photos').then(suc, err);
//suc recieves an object describing the contents of the form below
{
  files: [
    {
      modified: string, //ISO timestamp last modified for the file
      name: string, //The filename as assigned by dev
      path: string, //The path of the file
      url: string, //A url that can be used to get the file
    }, ...
  ],
  collections: [
    {
      name: string, //The name of the collection
      path: string, //The path at which the file resides
    }
  ]
}
```
<a name="Replay"></a>
## Replay
The Replay class provides an API for interacting with an [Replay](/docs/appliances/Replay) Appliance

**Kind**: global typedef  
**See**: [here](/docs/appliances/Replay) for documentation.  
**Example**  
```js
**Query a Replay Channel**
//create a Replay instance from the domain
var replay = $riffle.xsReplay();

//get messages published to a channel between startts and stopts (seconds from epoch)
replay.getReplay('xs.demo.dev.app.user/messages', startts, stopts).then(handler, error);
```

* [Replay](#Replay)
    * [.addReplay()](#Replay.addReplay)
    * [.removeReplay()](#Replay.removeReplay)
    * [.pauseReplay()](#Replay.pauseReplay)
    * [.getReplay()](#Replay.getReplay)

<a name="Replay.addReplay"></a>
### Replay.addReplay()
**Kind**: static method of <code>[Replay](#Replay)</code>  
**See**: [here](/docs/appliances/Replay#addReplay) for documentation.  
**Example**  
```js
replay.addReplay(...args).then(success, error);
```
<a name="Replay.removeReplay"></a>
### Replay.removeReplay()
**Kind**: static method of <code>[Replay](#Replay)</code>  
**See**: [here](/docs/appliances/Replay#removeReplay) for documentation.  
**Example**  
```js
replay.removeReplay(...args).then(success, error);
```
<a name="Replay.pauseReplay"></a>
### Replay.pauseReplay()
**Kind**: static method of <code>[Replay](#Replay)</code>  
**See**: [here](/docs/appliances/Replay#pauseReplay) for documentation.  
**Example**  
```js
replay.pauseReplay(...args).then(success, error);
```
<a name="Replay.getReplay"></a>
### Replay.getReplay()
**Kind**: static method of <code>[Replay](#Replay)</code>  
**See**: [here](/docs/appliances/Replay#getReplay) for documentation.  
**Example**  
```js
replay.getReplay(...args).then(success, error);
```
<a name="RiffleStorage"></a>
## RiffleStorage
The RiffleStorage class links to a [Storage](/docs/appliances/Storage) appliance and allows for creating 
[collection](#RiffleCollection) objects.

**Kind**: global typedef  
**Example**  
```js
//create a RiffleStorage instance from the domain
var storage = $riffle.xsStorage(storageDomain);

//create a RiffleCollection 
var cars = storage.xsCollection('cars');
```

* [RiffleStorage](#RiffleStorage)
    * [.xsCollection(name)](#RiffleStorage.xsCollection)
    * [.list_collections()](#RiffleStorage.list_collections) ⇒ <code>promise</code>

<a name="RiffleStorage.xsCollection"></a>
### RiffleStorage.xsCollection(name)
create a [RiffleCollection](#RiffleCollection) instance to interact with the collection in the  [Storage](/docs/appliances/Storage) appliance.

**Kind**: static method of <code>[RiffleStorage](#RiffleStorage)</code>  

| Param | Type | Description |
| --- | --- | --- |
| name | <code>string</code> | The name of the collection in the [Storage](/docs/appliances/Storage) appliance. |

**Example**  
```js
//create a RiffleCollection 
var cars = storage.xsCollection('cars');
```
<a name="RiffleStorage.list_collections"></a>
### RiffleStorage.list_collections() ⇒ <code>promise</code>
Return all the collections for this [Storage](/docs/appliances/Storage) appliance and their contents.

**Kind**: static method of <code>[RiffleStorage](#RiffleStorage)</code>  
**Returns**: <code>promise</code> - - a promise that is resolve with an object with keys of the collection names and values which are arrays of the documents in the collection  
**Example**  
```js
//list collections
storage.list_collection().then(handler);
```
<a name="RiffleCollection"></a>
## RiffleCollection
The RiffleCollection class links to a [Storage](/docs/appliances/Storage) appliance and allows for interacting with
[collections](#RiffleCollection).

**Kind**: global typedef  
**Example**  
```js
//create a RiffleCollection 
var cars = storage.xsCollection('cars');
```

* [RiffleCollection](#RiffleCollection)
    * [.create_index()](#RiffleCollection.create_index)
    * [.delete_many()](#RiffleCollection.delete_many)
    * [.delete_one()](#RiffleCollection.delete_one)
    * [.distinct()](#RiffleCollection.distinct)
    * [.drop()](#RiffleCollection.drop)
    * [.drop_index()](#RiffleCollection.drop_index)
    * [.drop_indexes()](#RiffleCollection.drop_indexes)
    * [.find()](#RiffleCollection.find)
    * [.find_one()](#RiffleCollection.find_one)
    * [.find_one_and_delete()](#RiffleCollection.find_one_and_delete)
    * [.find_one_and_replace()](#RiffleCollection.find_one_and_replace)
    * [.find_one_and_update()](#RiffleCollection.find_one_and_update)
    * [.insert_one()](#RiffleCollection.insert_one)
    * [.insert_many()](#RiffleCollection.insert_many)
    * [.list_indexes()](#RiffleCollection.list_indexes)
    * [.rename()](#RiffleCollection.rename)
    * [.replace_one()](#RiffleCollection.replace_one)
    * [.update_one()](#RiffleCollection.update_one)
    * [.update_many()](#RiffleCollection.update_many)

<a name="RiffleCollection.create_index"></a>
### RiffleCollection.create_index()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.create_index) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.create_index(key).then(handler);
```
<a name="RiffleCollection.delete_many"></a>
### RiffleCollection.delete_many()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.delete_many) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.delete_many(filter).then(handler);
```
<a name="RiffleCollection.delete_one"></a>
### RiffleCollection.delete_one()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.delete_one) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.delete_one(filter).then(handler);
```
<a name="RiffleCollection.distinct"></a>
### RiffleCollection.distinct()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.distinct) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.distinct(key).then(handler);
```
<a name="RiffleCollection.drop"></a>
### RiffleCollection.drop()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.drop) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.drop().then(handler);
```
<a name="RiffleCollection.drop_index"></a>
### RiffleCollection.drop_index()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.drop_index) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.drop_index(key).then(handler);
```
<a name="RiffleCollection.drop_indexes"></a>
### RiffleCollection.drop_indexes()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.drop_indexes) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.drop_indexes().then(handler);
```
<a name="RiffleCollection.find"></a>
### RiffleCollection.find()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.find) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.find().then(handler);
```
<a name="RiffleCollection.find_one"></a>
### RiffleCollection.find_one()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.find_one) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.find_one(filter).then(handler);
```
<a name="RiffleCollection.find_one_and_delete"></a>
### RiffleCollection.find_one_and_delete()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.find_one_and_delete) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.find_one_and_delete(filter).then(handler);
```
<a name="RiffleCollection.find_one_and_replace"></a>
### RiffleCollection.find_one_and_replace()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.find_one_and_replace) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.find_one_and_replace(filter, replacement).then(handler);
```
<a name="RiffleCollection.find_one_and_update"></a>
### RiffleCollection.find_one_and_update()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.find_one_and_update) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.find_one_and_update(filter, update).then(handler);
```
<a name="RiffleCollection.insert_one"></a>
### RiffleCollection.insert_one()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.insert_one) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.insert_one(document).then(handler);
```
<a name="RiffleCollection.insert_many"></a>
### RiffleCollection.insert_many()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.insert_many) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.insert_many(documents).then(handler);
```
<a name="RiffleCollection.list_indexes"></a>
### RiffleCollection.list_indexes()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.list_indexes) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.list_indexes().then(handler);
```
<a name="RiffleCollection.rename"></a>
### RiffleCollection.rename()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.rename) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.rename(name).then(handler);
```
<a name="RiffleCollection.replace_one"></a>
### RiffleCollection.replace_one()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.replace_one) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.replace_one(filter, replacement).then(handler);
```
<a name="RiffleCollection.update_one"></a>
### RiffleCollection.update_one()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.update_one) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.update_one(filter, update).then(handler);
```
<a name="RiffleCollection.update_many"></a>
### RiffleCollection.update_many()
**Kind**: static method of <code>[RiffleCollection](#RiffleCollection)</code>  
**See**: [here](https://api.mongodb.org/python/current/api/pymongo/collection.html#pymongo.collection.Collection.update_many) for documentation **kwargs not supported only positional args**.  
**Example**  
```js
collection.update_many(filter, update).then(handler);
```

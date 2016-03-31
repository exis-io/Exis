# jsRiffle (v0.4.8)
jsRiffle is an JavaScript library that provides an API for connection and interaction with Exis.

## Changes in v0.4.8
* Bug fix where rejecting a promise that is being returned via a call results in the success handler being called on the receiving end.

## Objects

<dl>
<dt><a href="#jsRiffle">jsRiffle</a> : <code>object</code></dt>
<dd><p>jsRiffle is the client side JavaScript library for interacting with Exis</p>
</dd>
</dl>

## Typedefs

<dl>
<dt><a href="#ModelObject">ModelObject</a></dt>
<dd><p>The ModelObject class is used to to wrap a custom JavaScript class and provides an API for interaction with
Model Object Storage via a <a href="/docs/appliances/Storage">Storage</a> appliance. It can also be provided as an argument to
<a href="#jsRiffle.want">want</a> to ensure objects recieved have the correct properties 
and are constructed with the correct prototype.</p>
</dd>
<dt><a href="#RiffleConstructor">RiffleConstructor</a></dt>
<dd><p>A RiffleConstructor is simply a class constructor function with the expected property set to be the expected <code>Type</code>
This Constructor can be used to create a <a href="#ModelObject">ModelObject</a> via the <a href="#jsRiffle.modelObject">modelObject</a> function and used for as an expected
type for <a href="#jsRiffle.want">want</a>.</p>
</dd>
<dt><a href="#RiffleDomain">RiffleDomain</a></dt>
<dd><p>A RiffleDomain is an object which represents a specific <a href="/docs/riffle/Domain">domain</a> on Exis and
provides an API for performing actions such as <a href="#RiffleDomain.register">register</a> and <a href="#RiffleDomain.call">call</a> on behalf of the <a href="/docs/riffle/Domain">domain</a>.
The <a href="#jsRiffle.Domain">Domain</a> function returns a domain on a new connection using the string provided i.e. <code>xs.demo.user.app</code>. Creating subdomains from the <a href="#RiffleDomain">RiffleDomain</a>
would give us domain objects representing a domain like <code>xs.demo.user.app.subdomain</code>. Creating subdomains from any <code>RiffleDomain</code> always creates a new domain object
with its namespace one level lower than it&#39;s parent.</p>
</dd>
<dt><a href="#RifflePromise">RifflePromise</a></dt>
<dd><p>A RifflePromise is a regular Promise object that simply implements an extra <a href="#RifflePromise.want">want</a> function which specifies what the
expected result of a <a href="#RiffleDomain.call">call</a> should be.</p>
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

<a name="jsRiffle"></a>
## jsRiffle : <code>object</code>
jsRiffle is the client side JavaScript library for interacting with Exis

**Kind**: global namespace  
**Example**  
```js
//via Node.js
jsRiffle = require('jsriffle');
jsRiffle.Domain('xs.domain');

//access globally in browser
jsRiffle.Domain('xs.domain');
```

* [jsRiffle](#jsRiffle) : <code>object</code>
    * [.setFabric(url)](#jsRiffle.setFabric)
    * [.setFabricLocal()](#jsRiffle.setFabricLocal)
    * [.setFabricProduction()](#jsRiffle.setFabricProduction)
    * [.setFabricSandbox()](#jsRiffle.setFabricSandbox)
    * [.Domain(domain)](#jsRiffle.Domain) ⇒ <code>Domain</code>
    * [.modelObject(class)](#jsRiffle.modelObject) ⇒ <code>[ModelObject](#ModelObject)</code>
    * [.want(handler, ...types)](#jsRiffle.want) ⇒ <code>function</code>
    * [.xsStorage(domain)](#jsRiffle.xsStorage) ⇒ <code>[RiffleStorage](#RiffleStorage)</code>

<a name="jsRiffle.setFabric"></a>
### jsRiffle.setFabric(url)
Sets the url of the node being connected to.

**Kind**: static method of <code>[jsRiffle](#jsRiffle)</code>  

| Param | Type | Description |
| --- | --- | --- |
| url | <code>string</code> | The url of the node to be connected to. |

**Example**  
```js
//connect to exis sandbox node 
jsRiffle.setFabric('ws://sandbox.exis.io:8000/ws');
```
<a name="jsRiffle.setFabricLocal"></a>
### jsRiffle.setFabricLocal()
Connect to a node running locally.

**Kind**: static method of <code>[jsRiffle](#jsRiffle)</code>  
<a name="jsRiffle.setFabricProduction"></a>
### jsRiffle.setFabricProduction()
Connect to node.exis.io, the Exis production node.

**Kind**: static method of <code>[jsRiffle](#jsRiffle)</code>  
<a name="jsRiffle.setFabricSandbox"></a>
### jsRiffle.setFabricSandbox()
Connect to sandbox.exis.io, the Exis sandbox node.

**Kind**: static method of <code>[jsRiffle](#jsRiffle)</code>  
<a name="jsRiffle.Domain"></a>
### jsRiffle.Domain(domain) ⇒ <code>Domain</code>
Returns a new Domain object on a new connection.

**Kind**: static method of <code>[jsRiffle](#jsRiffle)</code>  
**Returns**: <code>Domain</code> - - A [Domain](Domain) object  

| Param | Type | Description |
| --- | --- | --- |
| domain | <code>string</code> | The domain. |

**Example**  
```js
//sets app to app1 domain 
var app = jsRiffle.Domain('xs.demo.user.app1');
```
<a name="jsRiffle.modelObject"></a>
### jsRiffle.modelObject(class) ⇒ <code>[ModelObject](#ModelObject)</code>
Creates a new modelObject class using the given properly formed [RiffleConstructor](#RiffleConstructor).

**Kind**: static method of <code>[jsRiffle](#jsRiffle)</code>  
**Returns**: <code>[ModelObject](#ModelObject)</code> - A new ModelObject that can be used for interacting with Model Object Storage and the
[want](#jsRiffle.want) syntax.  

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
var person = jsRiffle.modelObject(Person);
```
<a name="jsRiffle.want"></a>
### jsRiffle.want(handler, ...types) ⇒ <code>function</code>
Takes the handler and the expected types that the subscribe or register handler expects and ensures
that the handler is only called if the data is correctly formatted. If the type wanted is a [ModelObject](#ModelObject)
then the data is constructed to be of the proper [ModelObject](#ModelObject) class.

**Kind**: static method of <code>[jsRiffle](#jsRiffle)</code>  
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
var person = jsRiffle.modelObject(Person);

//register a function that accepts only a Number and a Person
//The caller will receive an error if the arguments aren't correct
//expects call that looks like app.call('isOlder', 18, {first: 'John', last: 'Doe', age: 21});
app.register('isOlder', jsRiffle.want(function(age, person){
  if(person.age > age){
    console.log(person.fullname + 'is older than ' + age);
  }
}, Number, person));
```
<a name="jsRiffle.xsStorage"></a>
### jsRiffle.xsStorage(domain) ⇒ <code>[RiffleStorage](#RiffleStorage)</code>
Creates a new [RiffleStorage](#RiffleStorage) class using the given properly formed [RiffleDomain](#RiffleDomain).

**Kind**: static method of <code>[jsRiffle](#jsRiffle)</code>  
**Returns**: <code>[RiffleStorage](#RiffleStorage)</code> - A new RiffleStorage object that can be used for interacting with a [Storage](/docs/appliances/Storage) appliance.  

| Param | Type | Description |
| --- | --- | --- |
| domain | <code>[RiffleDomain](#RiffleDomain)</code> | A valid [RiffleDomain](#RiffleDomain) that represents the [Storage](/docs/appliances/Storage) appliance. |

**Example**  
```js
//create a domain
var app = jsRiffle.Domain('xs.demo.dev.app');

//create a storage domain
var storageDomain = app.subdomain('Storage');

//create a storage instance from the domain
var storage = jsRiffle.xsStorage(storageDomain);

//create a collection 
var cars = storage.xsCollection('cars');

app.onJoin = function(){
  //query the connection on joining
  cars.find({color: 'red'}).then(handler); //gets all red car objects from storage
}

app.join();
```
<a name="ModelObject"></a>
## ModelObject
The ModelObject class is used to to wrap a custom JavaScript class and provides an API for interaction with
Model Object Storage via a [Storage](/docs/appliances/Storage) appliance. It can also be provided as an argument to
[want](#jsRiffle.want) to ensure objects recieved have the correct properties 
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
var person = jsRiffle.modelObject(Person);
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
person.find_one({first: 'Nick', last: 'Hyatt'}).then(function(nick){
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
person.find_one({first: 'Nick', last: 'Hyatt'}).then(function(nick){
  nick.delete(); //removes document from storage
});
```
<a name="ModelObject.bind"></a>
### ModelObject.bind(domain, [storage], [collection])
Bind this instance of the ModelObject with a collection of ModelObjects in a [Storage](/docs/appliances/Storage) appliance.
Any instances constructed from the orignal [RiffleConstructor](#RiffleConstructor) or that are created as the result of either a
[want[reg/sub]](#jsRiffle.want) or a [want[call]](#RifflePromise.want) will have the [save](#ModelObject+save) and [delete](#ModelObject+delete) functions attached to the instance.

**Kind**: static method of <code>[ModelObject](#ModelObject)</code>  

| Param | Type | Description |
| --- | --- | --- |
| domain | <code>[RiffleDomain](#RiffleDomain)</code> | A [RiffleDomain](#RiffleDomain) object representing the attached [Storage](/docs/appliances/Storage) appliance or a domain currently connected to Exis. |
| [storage] | <code>string</code> | The fully qualified domain of the [Storage](/docs/appliances/Storage) appliance which to bind this ModelObject collection. If none is provided the `domain` object is assumed to be the [Storage](/docs/appliances/Storage) appliance. |
| [collection] | <code>string</code> | The name of the collection to bind the instance to. If none is provide the name of the class passed to [modelObject](#jsRiffle.modelObject) is used. |

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
var person = jsRiffle.modelObject(Person);

//create a subdomain representing a Storage applinance
var storage = app.subdomain('Storage');

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
var person = jsRiffle.modelObject(Person);

//create a subdomain representing a Storage applinance
var storage = app.subdomain('Storage');

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
var person = jsRiffle.modelObject(Person);

//create a subdomain representing a Storage applinance
var storage = app.subdomain('Storage');

//bind the person ModelObject to the Storage appliance
person.bind(storage); //The collection will be named Person based on the class by default

//query for the first user named Nick
person.find_one({first: 'Nick'}).then(handleNick);
```
<a name="RiffleConstructor"></a>
## RiffleConstructor
A RiffleConstructor is simply a class constructor function with the expected property set to be the expected `Type`
This Constructor can be used to create a [ModelObject](#ModelObject) via the [modelObject](#jsRiffle.modelObject) function and used for as an expected
type for [want](#jsRiffle.want).

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
The [Domain](#jsRiffle.Domain) function returns a domain on a new connection using the string provided i.e. `xs.demo.user.app`. Creating subdomains from the [RiffleDomain](#RiffleDomain)
would give us domain objects representing a domain like `xs.demo.user.app.subdomain`. Creating subdomains from any `RiffleDomain` always creates a new domain object
with its namespace one level lower than it's parent.

**Kind**: global typedef  
**Example**  
```js
//create a valid domain
var app = jsRiffle.Domain('xs.demo.dev.app');
//construct a valid subdomain from app domain
var backend = app.subdomain('backend');

//call a function that our backend domain has registered as part of its API
backend.call('getData').then(handler);
```

* [RiffleDomain](#RiffleDomain)
    * [.getName()](#RiffleDomain.getName) ⇒ <code>string</code>
    * [.register(action, handler)](#RiffleDomain.register) ⇒ <code>Promise</code>
    * [.call(action, ...args)](#RiffleDomain.call) ⇒ <code>[RifflePromise](#RifflePromise)</code>
    * [.publish(channel, ...args)](#RiffleDomain.publish)
    * [.subscribe(channel, handler)](#RiffleDomain.subscribe) ⇒ <code>Promise</code>
    * [.unsubscribe(channel)](#RiffleDomain.unsubscribe)
    * [.unregister(action)](#RiffleDomain.unregister)
    * [.subdomain(name)](#RiffleDomain.subdomain) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
    * [.linkDomain(fullDomain)](#RiffleDomain.linkDomain) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
    * [.join()](#RiffleDomain.join)
    * [.leave()](#RiffleDomain.leave)
    * [.login([user])](#RiffleDomain.login) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
    * [.registerAccount(user)](#RiffleDomain.registerAccount) ⇒ <code>Promise</code>
    * [.setToken(token)](#RiffleDomain.setToken)
    * [.getToken()](#RiffleDomain.getToken) ⇒ <code>string</code>

<a name="RiffleDomain.getName"></a>
### RiffleDomain.getName() ⇒ <code>string</code>
Get the string representation of the domain.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Returns**: <code>string</code> - The string representation of the domain. i.e. `xs.demo.user.app`.  
**Example**  
```js
app.getName(); //returns 'xs.demo.developer.app'
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
| handler | <code>function</code> | The function that will handle any calls made to the registered endpoint or a valid [$riffle.want]($riffle.want) function. |

**Example**  
```js
//register an action call hello on our top level app domain. i.e. xs.demo.user.app/hello
app.register('hello', function(){
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
//call an action sum on with two numbers on our top level app domain. i.e. xs.demo.user.app/sum
var p = app.call('sum', 1, 1);

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
//publish the string 'hello' to the `ping` channel on our top level app domain. i.e. `xs.demo.user.app/ping`
app.publish('ping', 'hello');
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
| handler | <code>function</code> | The function that will handle any publishes made to the registered endpoint or a valid [want](#jsRiffle.want) function. |

**Example**  
```js
//subscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
app.subscribe('hello', function(){
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
//unsubscribe to events published to hello on our top level app domain. i.e. xs.demo.user.app/hello
app.unsubscribe('hello');
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
//unregister the 'getData' action handler on our top level app domain. i.e. xs.demo.user.app/getData
app.unregister('getData');
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
//if app represents the domain xs.demo.user.app backend is a [RiffleDomain](#RiffleDomain) that represents `xs.demo.user.app.backend`
var backend = app.subdomain('backend');
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
//create a new domain that represents xs.demo.partner.app
var anotherApp = app.linkDomain('xs.demo.partner.app');
```
<a name="RiffleDomain.join"></a>
### RiffleDomain.join()
Attempts to create a connection to the Exis fabric using this domain. If successful a the `app.onJoin` function will be called
to notify a successful connection was established.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Example**  
```js
//if the join is successful this function will be triggered
app.onJoin = function(){
  console.log('Connected!');
};

//attempt to join connect to Exis as the top level domain i.e. xs.demo.user.app
app.join();
```
<a name="RiffleDomain.leave"></a>
### RiffleDomain.leave()
Unregister and unsubscribe anything in the domain and disconnect from Exis if this the the domain that [join](#RiffleDomain.join) was called on.
If the connection is closed the `onLeave` will be called notifying that the session has been closed.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Example**  
```js
//if the connection is closed this function will be triggered
app.onLeave = function(){
  console.log('Connection Closed!');
};

//unregister/unsubscribe any handlers on the top level domain and close the connection if it this the the domain join was called on.
app.leave();
```
<a name="RiffleDomain.login"></a>
### RiffleDomain.login([user]) ⇒ <code>[RiffleDomain](#RiffleDomain)</code>
Log the user in via the [Auth](/docs/appliances/Auth) appliance for this app and open the connection to Exis.
If the attached Auth appliance is level 1 then the user object must be provided. For level 0 you can call login with an empty object
to connect with at temporary random username. Passing in just the username will attempt to login the user with the given username
if it is available.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Returns**: <code>[RiffleDomain](#RiffleDomain)</code> - returns a promise object which is resolved upon success or rejected on failure.  

| Param | Type | Description |
| --- | --- | --- |
| [user] | <code>object</code> | An object containing the login info for the user. |
| user.username | <code>string</code> | The user's username as registered with Auth. |
| [user.password] | <code>string</code> | The user's password. |

**Example**  
```js
var user = { username: "example", password: "demo" };
//login user 
app.login(user).then(function(user_domain){
    //now we can connect the user
    user_domain.join();
  }, errorHandler);
```
<a name="RiffleDomain.registerAccount"></a>
### RiffleDomain.registerAccount(user) ⇒ <code>Promise</code>
Register a new user with an an Auth appliance attached to the current app domain. Only works with [Auth](/docs/appliances/Auth) appliances of level 1.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
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
var user = { username: "example", password: "demo", name: "Johnny D", email: "example@domain.com" };
//register the new user 
app.registerAccount(user).then(registerHandler, errorHandler);
```
<a name="RiffleDomain.setToken"></a>
### RiffleDomain.setToken(token)
Manually set a token to use for authentication for access to the Exis fabric.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  

| Param | Type | Description |
| --- | --- | --- |
| token | <code>string</code> | The token for the [domain](/docs/riffle/Domain) that is attempting to join the fabric. |

<a name="RiffleDomain.getToken"></a>
### RiffleDomain.getToken() ⇒ <code>string</code>
Retrieve the currently be used for authentication.

**Kind**: static method of <code>[RiffleDomain](#RiffleDomain)</code>  
**Returns**: <code>string</code> - returns the token currently being used for authenticating to Exis if there is one.  
<a name="RifflePromise"></a>
## RifflePromise
A RifflePromise is a regular Promise object that simply implements an extra [want](#RifflePromise.want) function which specifies what the
expected result of a [call](#RiffleDomain.call) should be.

**Kind**: global typedef  
**Example**  
```js
//call a function that and only execute our handler if the result is a string
app.call('getData').want(String).then(handler);
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
//call a function that and only execute our handler if the result is a string
app.call('getData').want(String).then(handler);
```
<a name="RiffleStorage"></a>
## RiffleStorage
The RiffleStorage class links to a [Storage](/docs/appliances/Storage) appliance and allows for creating 
[collection](#RiffleCollection) objects.

**Kind**: global typedef  
**Example**  
```js
//create a RiffleStorage instance from the domain
var storage = jsRiffle.xsStorage(storageDomain);

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
